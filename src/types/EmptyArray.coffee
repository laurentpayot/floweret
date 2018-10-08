import Type from './Type'

class EmptyArray extends Type
	# no argument
	argsMin: 0
	argsMax: 0
	constructor: -> super(arguments...)
	validate: (val) -> Array.isArray(val) and not val.length
	getTypeName: -> "empty array"

export default Type.createHelper(EmptyArray)
