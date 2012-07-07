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

	currentLine = 0
	emitter = new process.EventEmitter
	stanza = {}
	currentField = null
	isMultiLine = false
	previousLine = null

	createParseError = (msg) ->
		err = new Error msg
		err.controlLine = currentLine
		return err

	lineHandler = (line) ->
		line = line.replace "\r", ""
		currentLine++

		# Comments should be ignored completely.
		return if regex.comment.test line

		# Empty line = done with this stanza, emit it and reset state.
		# Note we're doing this on the next line, we have to do this because
		# there's an awesome ambiguity in control files - they don't use correct
		# blank line syntax (space followed by dot), so we don't know if these 
		# are the end of a stanza, or a blank continuation line. We resolve this
		# by checking the next line, if it's a continuation line, we don't end
		# the stanza just yet.
		if previousLine?.trim()?.length is 0 and not regex.continuationLine.test line
			emitter.emit "stanza", stanza if Object.keys(stanza).length
			stanza = {}
			currentField = null
			isMultiLine = false

		previousLine = line

		if regex.blankLine.test line
			return errorHandler createParseError "Blank continuation line without originating field." unless currentField
			isMultiLine = true
			stanza[currentField] += "\n"
		else if matches = regex.continuationLine.exec line
			return errorHandler createParseError "Continuation line without originating field." unless currentField
			isMultiLine = true
			line = matches[1] + matches[2]
			stanza[currentField] += "\n#{line}"
		else if matches = regex.simpleField.exec line
			[name, value] = matches.slice 1

			# If previous field wasn't multiline, we're safe to clean it up now.
			if currentField and not isMultiLine
				stanza[currentField] = stanza[currentField].trim()
				isMultiLine = false
			stanza[currentField = name] = value
	cleanup = ->
		splitter.removeListener "token", lineHandler
		splitter.removeListener "error", errorHandler
	errorHandler = (err) ->
		emitter.emit "error", err
		cleanup()

	splitter.on "token", lineHandler
	splitter.on "error", errorHandler
	splitter.on "done", ->
		cleanup()
		stanza[currentField] = stanza[currentField].trim() if currentField and not isMultiLine
		emitter.emit "stanza", stanza if Object.keys(stanza).length
		emitter.emit "done"

	return emitter
