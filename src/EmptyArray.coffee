CustomType = require './CustomType'

class EmptyArray extends CustomType
	# no argument
	argsMin: 0
	argsMax: 0
	constructor: -> super(arguments...)
	validate: (val) -> Array.isArray(val) and not val.length
	getTypeName: -> "empty array"

module.exports = CustomType.createHelper(EmptyArray)
