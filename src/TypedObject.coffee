CustomType = require './CustomType'
{isType, isAnyType, getTypeName} = require '.'

class TypedObject extends CustomType
	constructor: (@type) ->
		super(arguments, 1, 1) # exactly 1 argument
		CustomType.warn "Use 'Object' type instead of a #{@constructor.name}
						with values of any type." if isAnyType(@type)
	validate: (val) ->
		return false unless val?.constructor is Object
		return true if isAnyType(@type)
		Object.values(val).every((v) => isType(v, @type))
	getTypeName: -> "object with values of type '#{getTypeName(@type)}'"

module.exports = CustomType.createHelper(TypedObject)
