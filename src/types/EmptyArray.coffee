{Type} = require '.'

class EmptyArray extends Type
	constructor: -> super(arguments, 0, 0) # no arguments
	validate: (val) -> Array.isArray(val) and not val.length
	typeName: -> "empty array"

module.exports = Type.createHelper(EmptyArray)
