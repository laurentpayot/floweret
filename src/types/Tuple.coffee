{Type} = require './Type'
{isAnyType, isType, typeName} = require '..'

class _Tuple extends Type
	constructor: (@types...) ->
		super()
		error "!Tuple must have at least two type arguments." if arguments.length < 2
		return Array if @types.every((t) -> isAnyType(t)) # return needed
	validate: (val) ->
		return false unless Array.isArray(val) and val.length is @types.length
		val.every((e, i) => isType(e, @types[i]))
	typeName: ->
		"tuple of #{@types.length} elements '#{(typeName(t) for t in @types).join(", ")}'"

Tuple = (args...) -> new _Tuple(args...)

module.exports = {Tuple}
