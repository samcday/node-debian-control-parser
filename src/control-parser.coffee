StreamSplitter = require "stream-splitter"

regex = 
	comment: /^#.*$/
	blankLine: /^\s\..*$/
	simpleField: /^([^\cA-\cZ\s:]+):\s*(.*)$/
	continuationLine: /^(\s+)(.*)$/

# Parses Debian control files as per spec @ http://www.debian.org/doc/debian-policy/ch-controlfields.html
module.exports = ControlDataParser = (stream) ->
	splitter = stream.pipe StreamSplitter("\n")
	splitter.encoding = "utf8"

	emitter = new process.EventEmitter
	stanza = {}
	currentField = null
	isMultiLine = false
	tokenHandler = (token) ->
		# Empty line = done with this stanza, emit it and reset state.
		if token.trim().length is 0
			emitter.emit "stanza", stanza
			stanza = {}
			currentField = null
			isMultiLine = false
			return

		# Comments should be ignored completely.
		return if regex.comment.test token

		if regex.blankLine.test token
			return errorHandler new Error "Blank continuation line without originating field." unless currentField
			isMultiLine = true
			stanza[currentField] += "\n"
		else if matches = regex.continuationLine.exec token
			return errorHandler new Error "Continuation line without originating field." unless currentField
			isMultiLine = true
			line = matches[1] + matches[2]
			stanza[currentField] += "\n#{line}"
		else if matches = regex.simpleField.exec token
			[name, value] = matches.slice 1

			# If previous field wasn't multiline, we're safe to clean it up now.
			if currentField and not isMultiLine
				stanza[currentField] = stanza[currentField].trim()
				isMultiLine = false
			stanza[currentField = name] = value
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
		stanza[currentField] = stanza[currentField].trim() if currentField and not isMultiLine
		emitter.emit "stanza", stanza if stanza
		emitter.emit "done"

	return emitter
