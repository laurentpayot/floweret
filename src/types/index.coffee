class CustomTypeError extends Error
	constructor: (msg) -> super("Type error: " + msg)

class Type
	constructor: ->
		if @constructor is Type then throw new CustomTypeError("Abstract class 'Type' cannot be instantiated directly.")

createHelper = (childClass, asFunction=true) ->
	h = -> new childClass(arguments...)
	h.parentClass = Type
	h.class = childClass
	h.asFunction = asFunction
	h

module.exports ={Type, CustomTypeError, createHelper}
