class InvalidTypeError extends Error
	constructor: (msg) -> super("Type error: " + msg)

class Type
	constructor: ->
		throw new InvalidTypeError("Abstract class 'Type' cannot be instantiated directly.") if @constructor is Type
	validate: -> false # false if child class valitate missing

createHelper = (childClass, asFunction=false) ->
	h = -> new childClass(arguments...)
	h.rootClass = Type
	h.class = childClass
	h.asFunction = asFunction
	h

module.exports = {Type, InvalidTypeError, createHelper}
