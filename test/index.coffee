ControlParser = require "../src/control-parser"
fs = require "fs"
path = require "path"

simpleFile = path.join __dirname, "fixtures", "simple"
multiLineFile = path.join __dirname, "fixtures", "multiline"
simpleWhitespaceFile = path.join __dirname, "fixtures", "simplewhitespace"
noFieldSeparationFile = path.join __dirname, "fixtures", "nofieldseparation"
commentsFile = path.join __dirname, "fixtures", "comments"
blankLineFile = path.join __dirname, "fixtures", "blankline"
multipleStanzasFile = path.join __dirname, "fixtures", "multiplestanzas"

parseStanzaAndDone = (file, done, stanzaCb) ->
	control = ControlParser fs.createReadStream file
	gotStanza = false
	control.on "done", ->
		gotStanza.should.be.true
		done()
	control.on "stanza", (stanza) ->
		stanzaCb(stanza)
		gotStanza = true

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
	it "works with multiple stanzas", (done) ->
		control = ControlParser fs.createReadStream multipleStanzasFile
		stanzas = []
		control.on "stanza", (stanza) -> stanzas.push stanza
		control.on "done", ->
			stanzas.length.should.equal 3
			stanzas[0].should.eql Foo: "1.1", Bar: "1.2"
			stanzas[1].should.eql Foo: "2.1", Bar: "2.2"
			stanzas[2].should.eql Foo: "3.1", Bar: "3.2"
			done()