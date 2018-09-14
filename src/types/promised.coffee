{Type} = require '.'
{isAnyType} = require '..'

class Promised extends Type
	constructor: (@type) ->
		super(arguments, 1, 1) # exactly 1 argument
		# return needed to always return an array instead of a new Promised instance
		return if isAnyType(@type) then Promise else Promise.resolve(@type)
	helperName: "promised"

module.exports = Type.createHelper(Promised)
