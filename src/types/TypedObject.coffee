{Type, CustomTypeError} = require '.'
{isAnyType, isType, typeName} = require '..'

class TypedObject extends Type
	constructor: (@type) ->
		super()
		error "!TypedObject must have exactly one type argument." unless arguments.length is 1
		return Object if isAnyType(@type) # return needed
	validate: (val) ->
		return false unless val?.constructor is Object
		return true if isAnyType(@type)
		Object.values(val).every((v) => isType(v, @type))

module.exports = -> new TypedObject(arguments...)
