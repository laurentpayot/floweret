CustomType = require './CustomType'
{isAnyType} = require '.'

class Promised extends CustomType
	constructor: (@type) ->
		super(arguments, 1, 1) # exactly 1 argument
		CustomType.warn "Use 'Promise' type instead of '#{@helperName}(AnyType)'." if isAnyType(@type)
		# return needed to always return a promise instead of a new Promised instance
		return Promise.resolve(@type)
	helperName: "promised"

module.exports = CustomType.createHelper(Promised)
