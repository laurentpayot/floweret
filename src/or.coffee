CustomType = require './CustomType'
{isAnyType, getTypeName} = require '.'

class Or extends CustomType
	constructor: (@types...) ->
		super(arguments, 2) # 2 or more arguments
		# return needed to always return an array instead of a new Or instance
		return if @types.some((t) -> isAnyType(t)) then [] else @types
	helperName: "or"

module.exports = CustomType.createHelper(Or)
