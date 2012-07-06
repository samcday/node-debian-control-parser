# debian-control-parser `0.1.0`

[![build status](https://secure.travis-ci.org/samcday/node-debian-control-parser.png)](http://travis-ci.org/samcday/node-debian-control-parser)

A small Node.js library to parse control data used in Debian repositories.

## Example

Example control file:

	Name: debian-control-parser
	Status: sexy and knows it
	Description: This is multi
	 line, bebbe.

```javascript
var ControlParser = require("debian-control-parser");
var fs = require("fs");

control = ControlParser(fs.createReadStream("debcontrolfile"));
control.on("stanza", function(stanza) {
	console.log(stanza.Name); // "debian-control-parser"
	console.log(stanza.Status); // "sexy and knows it"
	console.log(stanza.Description); // "This is multi\n line, bebbe."
});
control.on("done", function() {
	console.log(" ... And that's the way the cookie crumbles.");
});
```

## API

```javascript
var ControlParser = require("debian-control-parser");
```

ControlParser accepts a single argument, a `ReadableStream` containing control data. It will return an `EventEmitter` that emits `stanza` events and `done` when there are no more stanzas left in control data.

* _emitter_ = ControlParser(_readableStream_);

## (Un)License

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
