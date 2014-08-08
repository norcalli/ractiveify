require! {
  'through'
  'tosource'
  'path'
  livescript: 'LiveScript'
  Ractive: 'ractive'
}

parseAndCompile = (file, data, options, cb) ->
  try
    parsed = Ractive.parse data, do
      noStringify: true
      interpolate:
        script: false
        style: false

    links = []
    scripts = []
    styles = []

    # Extract certain top-level nodes from the template. We work backwards
    # so that we can easily splice them out as we go
    template = parsed.t
    i = template.length
    while i--
      item = template[i]
      if not (item and item.t is 7)
        continue
      switch item.e
      case \link
        if item.a and item.a.rel is 'ractive'
          links.push template.splice(i, 1)[0]
      case \style
        if not item.a or not item.a.type or item.a.type is 'text/css'
          styles.push template.splice(i, 1)[0]
      case \script
        if not item.a or not item.a.type
          scripts.push template.splice(i, 1)[0]
        else if item.a.type is 'text/javascript'
          scripts.push template.splice(i, 1)[0]
        else if item.a.type of options.compilers
          script = template.splice(i, 1)[0]
          # console.log("Compiling:", item.a.type, item.f);
          filename = file + ".ls"
          source = script.f[0]
          script.f[0] = options.compilers[item.a.type](filename, source)
          scripts.push script
        # By default it always removes the script if not supported.
        else if options.onlySupported
          template.splice(i, 1)[0]

    imports = [{name, href} for {a: {name, href}} in links]
    script = [..f for scripts].join(';')
    css = [..f for styles].join ' '

    # TODO: Why am i using two newlines?
    compiled = "var component = module;\n\n"
    compiled += script
    # Parsed is template
    compiled += "\n\ncomponent.exports.template = #{tosource parsed}" if parsed
    compiled += "\n\ncomponent.exports.css = #{tosource css}" if css

    cb null, compiled
  catch error
    cb error

const livescriptCompiler = (file, data) ->
  livescript.compile data,
    bare: true
    header: false
    filename: file

const default-options =
  compilers:
    "text/livescript": livescriptCompiler
  onlySupported: true
  extensions: ['ract', 'rtv']

callback = (file, options) !->
  data = ""
  pattern = "\\.(#{options.extensions.join "|"})$"
  regex = new RegExp pattern
  # return through() unless /\.ract$/.test file
  return through() unless regex.test file
  stream = through(write, end)
  return stream

  !function write (buf)
    data += buf

  !function end
    parseAndCompile file, data, options, (error, result) !->
      stream.emit "error", error  if error
      stream.queue result
      stream.queue null

module.exports = (user-options) !->
  if typeof user-options == 'string'
    return callback file, default-options
  else
    options = {} <<< default-options <<< user-options
    return (file) -> callback file, options

