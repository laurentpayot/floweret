Type = require '.'

class AnyType extends Type
	constructor: -> super(arguments, 0, 0) # no arguments
	validate: (val) -> true
	getTypeName: -> "any type"

module.exports = Type.createHelper(AnyType)
