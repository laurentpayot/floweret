class CustomTypeError extends Error
	constructor: (msg) -> super("Custom type error: " + msg)

class Type
	constructor: ->
		if @constructor is Type then throw new CustomTypeError("Abstract class 'Type' cannot be instantiated directly.")

createHelper = (childClass, asFunctionArgs) ->
	h = -> new childClass(arguments...)
	h.parentClass = Type
	h.class = childClass
	h.asFunctionArgs = asFunctionArgs
	h

module.exports ={Type, CustomTypeError, createHelper}
