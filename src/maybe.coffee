CustomType = require './CustomType'
{isAnyType} = require '.'

class Maybe extends CustomType
	constructor: (@type) ->
		super(arguments, 1, 1) # exactly 1 argument
		CustomType.warn "AnyType is not needed as '#{@helperName}' argument." if isAnyType(@type)
		# return needed to always return an array instead of a new Maybe instance
		return [undefined, null, @type]
	helperName: "maybe"

module.exports = CustomType.createHelper(Maybe)
