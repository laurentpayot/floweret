CustomType = require './CustomType'
{isAnyType} = require '.'

class Maybe extends CustomType
	constructor: (@type) ->
		super(arguments, 1, 1) # exactly 1 argument
		# return needed to always return an array instead of a new Maybe instance
		return if isAnyType(@type) then [] else [undefined, null, @type]
	helperName: "maybe"

module.exports = CustomType.createHelper(Maybe)
