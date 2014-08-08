# Ractiveify

Browserify transform for ractive components (and by extension templates) which allows for compilation of embedded scripts and styles!

This module plays very nicely with `debowerify` and `deamdify`! I'm using it in my current project. Which is why I don't have any tests...yet...

# Example

```
{{#each filter(messages)}}
<p>{{.}}</p>
{{/each}}

<style type='text/scss'>
$base-color: #abc;

.p {
  font-color: $base-color;
}
</style>

<script type='text/ls'>
components.exports =
  init: ->
  data:
    filter: -> [.. for it when /monkey/i != ..]
    messages: ['Cat', 'Dog', 'Squirrel', 'Monkey', 'Mankey']
</script>
```

# Usage, API, and extension

## var ractiveify = require('ractiveify');

Initialization

## ractiveify.removeUnsupported

Default: `ractiveify.removeUnsupported = true`

A `<script>` tag without a type is assumed to be `text/javascript` and a
`<style>` tag without a type is assumed to be `test/css`.

If a type can't be matched in `ractiveify.compilers`, then `removeUnsupported = true`
means that these tags will not show up in the output.

## ractiveify.extensions

Default: `ractiveify.extensions = ['ract', 'rtv']`

## ractiveify.compilers

Currently I added support for `coffeescript` and `livescript`.

Default:
```
ractiveify.compilers = {
  'text/livescript': livescript,
  'text/ls': livescript,
  'text/coffeescript': coffeescript,
  'text/coffee': coffeescript,
  'text/coffee-script': coffeescript
}
```

Just register the mime-type you would use in the `type` attribute for the script
and then add the function to compile it.

The format: `ractiveify.compilers['text/butt'] = function(filename, scriptSource) {...}`

### Example addon for scss!

```
require! {
  'path'
  'node-sass'
}

ractiveify.compilers['text/scss'] = (file, data) ->
  sass.renderSync {data: data, includePaths: ['assets/stylesheets', path.dirname file]}
```
