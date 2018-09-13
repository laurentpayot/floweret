{Type, InvalidTypeError, createHelper} = require '.'
{isType, isAnyType} = require '..'

class TypedSet extends Type
	constructor: (@type) ->
		super(arguments, 1, 1) # 1 argument
		return Set if isAnyType(@type) # return needed
	validate: (val) ->
		return false unless val?.constructor is Set
		return true if isAnyType(@type)
		throw new InvalidTypeError "Typed Set type can not be a literal
									of type '#{@type}'." if @type?.constructor in [undefined, String, Number, Boolean]
		[val...].every((e) => isType(e, @type))

module.exports = createHelper(TypedSet)
