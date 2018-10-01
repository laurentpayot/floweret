CustomType = require './CustomType'
{isType, isAnyType, isLiteral, getTypeName} = require '.'

class TypedSet extends CustomType
	constructor: (@type) ->
		super(arguments, 1, 1) # exactly 1 argument
		@error "You cannot have #{getTypeName(@type)} as '#{@constructor.name}' argument." if isLiteral(@type)
		@warn "Use 'Set' type instead of a #{@constructor.name} with elements of any type." if isAnyType(@type)
	validate: (val) ->
		return false unless val?.constructor is Set
		return true if isAnyType(@type)
		[val...].every((e) => isType(e, @type))
	getTypeName: -> "set of '#{getTypeName(@type)}'"

module.exports = CustomType.createHelper(TypedSet)
