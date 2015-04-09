var Ractive = require("ractive");
Ractive.DEBUG = false;
var template = require("./test.ract");

var MyRactive = Ractive.extend(template);

var ractive = new MyRactive({
  el: "#container",
  data: { greeting: 'Hello', name: 'world' }
});
