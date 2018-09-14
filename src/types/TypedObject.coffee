CustomType = require '.'
{isType, isAnyType} = require '..'

class TypedObject extends CustomType
	constructor: (@type) ->
		super(arguments, 1, 1) # exactly 1 argument
		return Object if isAnyType(@type) # return needed
	validate: (val) ->
		return false unless val?.constructor is Object
		return true if isAnyType(@type)
		Object.values(val).every((v) => isType(v, @type))

module.exports = CustomType.createHelper(TypedObject)
