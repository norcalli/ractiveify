var browserify = require("browserify");
var b = browserify();
b.transform("./");
b.add("./test/main.js");
b.bundle(function(err, buf) {
  if (err) {
    throw err;
  }
  eval(buf.toString());
});
