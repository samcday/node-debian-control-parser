ControlParser = require "../src/control-parser"
fs = require "fs"
path = require "path"

simpleFile = path.join __dirname, "fixtures", "simple"

describe "ControlParser", ->
	it "works with simple fields", (done) ->
		control = ControlParser fs.createReadStream simpleFile

		control.on "paragraph", (paragraph) ->
			console.log arguments
			paragraph.Foo.should.equal "hello"
			paragraph.Foo.should.equal "world"

		control.on "done", done