{InvalidTypeError} = require '.'

AnyType = ->
	throw new InvalidTypeError "'AnyType' can not have a type argument." if arguments.length
	# returns the function itself
	AnyType

module.exports = AnyType
