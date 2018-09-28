CustomType = require './CustomType'
{isType, isAnyType, typeOf, getTypeName} = require '.'

class And extends CustomType
	constructor: (@types...) ->
		super(arguments, 2) # or more arguments
		for t, i in @types
			CustomType.warn "AnyType is not needed as '#{@helperName}' argument number #{i+1}." if isAnyType(t)
			CustomType.warn "Literal #{typeOf(t)} (#{t}) not needed as '#{@helperName}' argument number
							#{i+1}." if typeOf(t) in ['undefined', 'null', 'Number', 'String', 'Boolean', 'NaN']
	validate: (val) -> @types.every((t) -> isType(val, t))
	getTypeName: -> ("'#{getTypeName(t)}'" for t in @types).join(" and ")
	helperName: "and"

module.exports = CustomType.createHelper(And)
