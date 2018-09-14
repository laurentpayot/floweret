CustomType = require './CustomType'
{isAnyType} = require '.'

class Maybe extends CustomType
	constructor: (@types...) ->
		super(arguments, 1) # 1 or more arguments
		# return needed to always return an array instead of a new Maybe instance
		return if @types.some((t) -> isAnyType(t)) then [] else [undefined, null].concat(@types)
	helperName: "maybe"

module.exports = CustomType.createHelper(Maybe)
