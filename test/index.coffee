ControlParser = require "../src/control-parser"
fs = require "fs"
path = require "path"

simpleFile = path.join __dirname, "fixtures", "simple"
whitespaceFile = path.join __dirname, "fixtures", "whitespace"
noFieldSeparationFile = path.join __dirname, "fixtures", "nofieldseparation"

describe "ControlParser", ->
	it "works with simple fields", (done) ->
		control = ControlParser fs.createReadStream simpleFile
		control.on "paragraph", (paragraph) ->
			paragraph.should.have.property "Foo"
			paragraph.should.have.property "Bar"
			paragraph.Foo.should.equal "hello"
			paragraph.Bar.should.equal "world"
		control.on "done", done
	it "handles extraneous whitespace correctly", (done) ->
		control = ControlParser fs.createReadStream whitespaceFile
		control.on "paragraph", (paragraph) ->
			paragraph.should.have.property "Foo"
			paragraph.should.have.property "Bar"
			paragraph.Foo.should.equal "hello"
			paragraph.Bar.should.equal "world"
		control.on "done", done
	it "handles no field whitespace separation correctly", (done) ->
		control = ControlParser fs.createReadStream noFieldSeparationFile
		control.on "paragraph", (paragraph) ->
			paragraph.should.have.property "Foo"
			paragraph.Foo.should.equal "hello"
		control.on "done", done
