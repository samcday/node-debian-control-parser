ControlParser = require "../src/control-parser"
fs = require "fs"
path = require "path"

simpleFile = path.join __dirname, "fixtures", "simple"
multiLineFile = path.join __dirname, "fixtures", "multiline"
simpleWhitespaceFile = path.join __dirname, "fixtures", "simplewhitespace"
noFieldSeparationFile = path.join __dirname, "fixtures", "nofieldseparation"
commentsFile = path.join __dirname, "fixtures", "comments"
blankLineFile = path.join __dirname, "fixtures", "blankline"

parseStanzaAndDone = (file, done, stanzaCb) ->
	control = ControlParser fs.createReadStream file
	control.on "done", done
	control.on "stanza", stanzaCb

describe "ControlParser", ->
	it "works with simple fields", (done) ->
		parseStanzaAndDone simpleFile, done, (stanza) ->
			stanza.should.have.property "Foo"
			stanza.should.have.property "Bar"
			stanza.Foo.should.equal "hello"
			stanza.Bar.should.equal "world"
	it "handles extraneous whitespace for simple fields correctly", (done) ->
		parseStanzaAndDone simpleWhitespaceFile, done, (stanza) ->
			stanza.should.have.property "Foo"
			stanza.should.have.property "Bar"
			stanza.Foo.should.equal "hello"
			stanza.Bar.should.equal "world"
	it "handles no field whitespace separation correctly", (done) ->
		parseStanzaAndDone noFieldSeparationFile, done, (stanza) ->
			stanza.should.have.property "Foo"
			stanza.Foo.should.equal "hello"
	it "works with multiline fields", (done) ->
		parseStanzaAndDone multiLineFile, done, (stanza) ->
			stanza.should.have.property "Foo"
			stanza.should.have.property "Bar"
			stanza.Foo.should.equal "hello\n  world!"
			stanza.Bar.should.equal "hello\n\t\tworld!"
	it "works with comment lines", (done) ->
		parseStanzaAndDone commentsFile, done, (stanza) ->
			stanza.should.have.property "Foo"
			stanza.Foo.should.equal "hello\n world!"
	it "works with blank lines", (done) ->
		parseStanzaAndDone blankLineFile, done, (stanza) ->
			stanza.should.have.property "Foo"
			stanza.Foo.should.equal "hello\n\n world!"
