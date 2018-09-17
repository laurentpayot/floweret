CustomType = require './CustomType'
{isType, isAnyType, getTypeName} = require '.'

class And extends CustomType
	constructor: (@types...) ->
		super(arguments, 2) # or more arguments
		for t, i in @types
			@warn "AnyType is not needed as '#{@helperName}' argument number #{i}." if isAnyType(t)
			@warn "Literal #{getTypeName(t)} (#{t}) not needed as '#{@helperName}' argument number
					#{i}." if typeof type? in ['undefined', 'number', 'string', 'boolean'] # typeof NaN is 'number'
	validate: (val) ->
		@types.every((t) -> isType(val, t))
	helperName: "and"

module.exports = CustomType.createHelper(And)
