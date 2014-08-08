require! {
  'through'
  'tosource'
  Ractive: 'ractive'
}

livescript = require __dirname + '/compilers/livescript.js'
coffeescript = require __dirname + '/compilers/coffeescript.js'

parseAndCompile = (file, data, cb) ->
  try
    parsed = Ractive.parse data, do
      noStringify: true
      interpolate:
        script: false
        style: false

    # TODO: links support in some way?
    links = []
    scripts = []
    # TODO: I could add scss support...
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
        if not item.a or not item.a.type
          styles.push template.splice(i, 1)[0]
        else if item.a.type is 'text/css'
          styles.push template.splice(i, 1)[0]
        else if item.a.type of ractiveify.compilers
          style = template.splice(i, 1)[0]
          # console.log("Compiling:", item.a.type, item.f);
          # TODO: Extension lookup?
          # filename = file + ".ls"
          source = style.f[0]
          style.f[0] = ractiveify.compilers[item.a.type](file, source)
          styles.push style
        # By default it always removes the script if not supported.
        else if ractiveify.removeUnsupported
          template.splice(i, 1)[0]
      case \script
        if not item.a or not item.a.type
          scripts.push template.splice(i, 1)[0]
        else if item.a.type is 'text/javascript'
          scripts.push template.splice(i, 1)[0]
        else if item.a.type of ractiveify.compilers
          script = template.splice(i, 1)[0]
          # console.log("Compiling:", item.a.type, item.f);
          # TODO: Extension lookup?
          # filename = file + ".ls"
          source = script.f[0]
          script.f[0] = ractiveify.compilers[item.a.type](file, source)
          scripts.push script
        # By default it always removes the script if not supported.
        else if ractiveify.removeUnsupported
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

ractiveify = (file) !->
  data = ""
  # Use a regex because path.extname wouldn't match .coffee.md.
  # TODO: Strip leading dot?
  pattern = "\\.(#{ractiveify.extensions.join "|"})$"
  regex = new RegExp pattern
  # return through() unless /\.ract$/.test file
  return through() unless regex.test file
  stream = through(write, end)
  return stream

  !function write (buf)
    data += buf

  !function end
    parseAndCompile file, data, (error, result) !->
      stream.emit "error", error  if error
      stream.queue result
      stream.queue null

# TODO: Make compilers optionally an array with extension as second
# EG:
# - text/ls: [livescript, '.ls']
ractiveify
  ..extensions = ['ract', 'rtv']
  ..removeUnsupported = true
  ..compilers =
    "text/livescript": livescript
    "text/ls": livescript
    "text/coffeescript": coffeescript
    "text/coffee": coffeescript
    "text/coffee-script": coffeescript

module.exports = ractiveify
