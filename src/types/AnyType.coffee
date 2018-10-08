import Type from './Type'

class AnyType extends Type
	# no arguments
	argsMin: 0
	argsMax: 0
	constructor: -> super(arguments...)
	validate: (val) -> true
	getTypeName: -> "any type"

export default Type.createHelper(AnyType)
