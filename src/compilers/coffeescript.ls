# Taken from jnordberg/coffeeify
require! {
  'through'
  'coffee-script': coffee
  'convert-source-map': convert
}

!function ParseError error, src, file
  /* Creates a ParseError from a CoffeeScript SyntaxError
     modeled after substack's syntax-error module */
  SyntaxError.call this

  this.message = error.message

  this.line = error.location.first_line + 1 # cs linenums are 0-indexed
  this.column = error.location.first_column + 1 # same with columns

  markerLen = 2
  if error.location.first_line == error.location.last_line
    markerLen += error.location.last_column - error.location.first_column;

  this.annotated = [
    file + ':' + this.line
    src.split('\n')[this.line - 1]
    Array(this.column).join(' ') + Array(markerLen).join('^')
    'ParseError: ' + this.message
  ].join('\n')

ParseError.prototype = Object.create SyntaxError.prototype

ParseError.prototype.toString = -> this.annotated

ParseError.prototype.inspect = -> this.annotated

function compile file, data
  compiled = null
  try
    compiled = coffee.compile data, do
      sourceMap: coffeeify.sourceMap
      generatedFile: file
      inline: true
      bare: true
      literate: isLiterate(file)
  catch error
    error = new ParseError e, data, file if error.location
    throw error
  if coffeeify.sourceMap
    map = convert.fromJSON compiled.v3SourceMap
    map.setProperty 'sources', [file]
    return compiled.js + '\n' + map.toComment() + '\n'
  else
    return compiled + '\n'

module.exports = compile

