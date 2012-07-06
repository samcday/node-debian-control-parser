StreamSplitter = require "stream-splitter"

regex = 
	comment: /^#.*$/
	blankLine: /^\s\..*$/
	simpleField: /^([^\cA-\cZ\s:]+):\s?(.*)$/
	continuationLine: /^\s(.*)$/

# Parses Debian control files as per spec @ http://www.debian.org/doc/debian-policy/ch-controlfields.html
module.exports = ControlDataParser = (stream) ->
	splitter = stream.pipe StreamSplitter("\n")
	splitter.encoding = "utf8"

	emitter = new process.EventEmitter
	paragraph = {}
	currentField = null
	tokenHandler = (token) ->
		if token.trim().length is 0
			emitter.emit "paragraph", paragraph
			paragraph = {}
			currentField = null
			return
		return if regex.comment.test token

		if matches = regex.continuationLine.exec token
			return errorHandler new Error "Continuation line without originating field." unless currentField
			paragraph[currentField] += "\n#{matches[1].trim()}"
		else if regex.blankLine.test token
			return errorHandler new Error "Blank continuation line without originating field." unless currentField
			paragraph[currentField] += "\n"
		else if matches = regex.simpleField.exec token
			[name, value] = matches.slice 1
			paragraph[currentField = name] = value.trim()
	cleanup = ->
		splitter.removeListener "token", tokenHandler
		splitter.removeListener "error", errorHandler
	errorHandler = (err) ->
		emitter.emit "error", err
		cleanup()

	splitter.on "token", tokenHandler
	splitter.on "error", errorHandler
	splitter.on "done", ->
		cleanup()
		emitter.emit "paragraph", paragraph if paragraph
		emitter.emit "done"

	return emitter
