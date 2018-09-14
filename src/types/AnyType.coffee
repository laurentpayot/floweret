CustomType = require '.'

class AnyType extends CustomType
	constructor: -> super(arguments, 0, 0) # no arguments
	validate: (val) -> true
	getTypeName: -> "any type"

module.exports = CustomType.createHelper(AnyType)
