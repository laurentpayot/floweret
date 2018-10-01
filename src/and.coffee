CustomType = require './CustomType'
{isType, isAnyType, typeOf, isLiteral, getTypeName} = require '.'

class And extends CustomType
	constructor: (@types...) ->
		super(arguments, 2) # or more arguments
		for t, i in @types
			@error "You cannot have #{getTypeName(t)} as '#{@helperName}' argument number #{i+1}." if isLiteral(t)
			@warn "AnyType is not needed as '#{@helperName}' argument number #{i+1}." if isAnyType(t)
	validate: (val) -> @types.every((t) -> isType(val, t))
	getTypeName: -> ("'#{getTypeName(t)}'" for t in @types).join(" and ")
	helperName: "and"

module.exports = CustomType.createHelper(And)
