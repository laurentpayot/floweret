CustomType = require './CustomType'
{isType, isAnyType, getTypeName} = require '.'

class Tuple extends CustomType
	constructor: (@types...) ->
		super(arguments, 2) # 2 or more arguments
		CustomType.warn "Use 'Array(#{@types.length})' type instead of a #{@constructor.name}
						of #{@types.length} values of any type'." if @types.every((t) -> isAnyType(t))
	validate: (val) ->
		return false unless Array.isArray(val) and val.length is @types.length
		val.every((e, i) => isType(e, @types[i]))
	getTypeName: ->
		"tuple of #{@types.length} elements '#{(getTypeName(t) for t in @types).join(", ")}'"

module.exports = CustomType.createHelper(Tuple)
