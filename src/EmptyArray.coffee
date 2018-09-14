CustomType = require './CustomType'

class EmptyArray extends CustomType
	constructor: -> super(arguments, 0, 0) # no arguments
	validate: (val) -> Array.isArray(val) and not val.length
	getTypeName: -> "empty array"

module.exports = CustomType.createHelper(EmptyArray)
