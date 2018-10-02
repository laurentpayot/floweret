CustomType = require './CustomType'
{isAnyType} = require '.'

class Maybe extends CustomType
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@warn "AnyType is not needed as '#{@helperName}' argument." if isAnyType(@type)
		# return needed to always return an array instead of a new Maybe instance
		return [undefined, null, @type]
	helperName: "maybe"

module.exports = CustomType.createHelper(Maybe)
