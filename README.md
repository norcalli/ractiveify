# Ractiveify

Browserify transform and general ractive component parser (see `ractiveify.parse` below).

Browserify transform for ractive [components](http://docs.ractivejs.org/latest/components) (and by extension templates) which allows for compilation of embedded scripts and styles!

This module plays very nicely with `debowerify` and `deamdify`! I'm using it in my current project. Which is why I don't have any tests...yet...

**However!** Debowerify (the original) filters out extensions. Which is why I made my own fork at `norcalli/debowerify` which
accepts an `extensions` option (`debowerify.extensions.push('ract')`). This is the only way
that `debowerify` will work with ractive components which have been `require`'d.

You can include this in your `package.json` by simply switching the version to `norcalli/debowerify`
like this:
```
"dependencies": {
  ...
  "debowerify": "norcalli/debowerify"
  ...
}
```

### Quick Tip
In case you didn't know, you could do:
```
var ractiveify = require('ractiveify');

ractiveify.extensions.push('ractive');

var b = browserify();
b.transform(ractiveify);
b.bundle();
```

# Example component file

## 'messages.ract'
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

## var messageTemplate = require('./messages.ract');

`messageTemplate` will then be populated as such:
```
messageTemplate == {
  template: ...
  css: ...
  init: function() {}
  data:
    filter: ...
    messages: ...
```

The transform will populate the `template` property with the markup, the
`css` property with the compiled output of your `<style>` tags and will
use the rest as parameters for `messageTemplate`.

You can then use the plugin by:
```
var MessageTemplate = Ractive.extend(require('./messages.ract'));

var messageComponent = MessageTemplate({
  el: container,
  data:
    messages: ['My', 'Better', 'Messages']
});
```

# Transform programmatic usage, API, and adding compilers

I will soon be adding the option to specify these things in `package.json`,
where compilers would be specified with filepaths.

## var ractiveify = require('ractiveify');

Initialization

## ractiveify.parse(filename, scriptSource, callback(errors, data))

I've exposed the parse method that I use in case anyone wants to use
this plugin as the basis for anything else as well.

- `filename` is mostly unimportant. It is passed forward to the compilers.

- `scriptSource` is the actual file contents of the component. Obviously required.

- `callback` is should be of the format `function(errors, data){}`

## ractiveify.removeUnsupported

Default:
```
ractiveify.removeUnsupported = true
```

A `<script>` tag without a type is assumed to be `text/javascript` and a
`<style>` tag without a type is assumed to be `test/css`.

If a type can't be matched in `ractiveify.compilers`, then `removeUnsupported = true`
means that these tags will not show up in the output.

## ractiveify.extensions

Default:
```
ractiveify.extensions = ['ract', 'rtv']
```

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

The format:
```
ractiveify.compilers['text/butt'] = function(filename, scriptSource) {...}
```

### Example addon for scss!

```
require! {
  'path'
  'node-sass'
}

ractiveify.compilers['text/scss'] = (file, data) ->
  sass.renderSync {data: data, includePaths: ['assets/stylesheets', path.dirname file]}
```
