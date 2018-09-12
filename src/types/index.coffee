class CustomTypeError extends Error
	constructor: (msg) -> super("Custom type error: " + msg)

class Type
	constructor: ->
		if @constructor is Type then throw new CustomTypeError("Abstract class 'Type' cannot be instantiated directly.")
	validate: -> false # false if child class valitate missing

createHelper = (childClass, asFunction=false) ->
	h = -> new childClass(arguments...)
	h.rootClass = Type
	h.class = childClass
	h.asFunction = asFunction
	h

module.exports ={Type, CustomTypeError, createHelper}
