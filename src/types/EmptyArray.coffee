{InvalidTypeError} = require '.'

EmptyArray = ->
	throw new InvalidTypeError "'EmptyArray' can not have a type argument." if arguments.length
	# returns the function itself
	EmptyArray

module.exports = EmptyArray
