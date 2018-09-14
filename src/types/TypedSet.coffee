Type = require '.'
{isType, isAnyType} = require '..'

class TypedSet extends Type
	constructor: (@type) ->
		super(arguments, 1, 1) # 1 argument
		return Set if isAnyType(@type) # return needed
		Type.error "'#{@constructor.name}' argument can not be a literal
					of type '#{@type}'." if @type?.constructor in [undefined, String, Number, Boolean]
	validate: (val) ->
		return false unless val?.constructor is Set
		return true if isAnyType(@type)
		[val...].every((e) => isType(e, @type))

module.exports = Type.createHelper(TypedSet)
