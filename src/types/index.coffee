class InvalidTypeError extends Error
	constructor: (msg) -> super("Type error: " + msg)


s = (n) -> if n is 1 then '' else 's'

class Type
	# rootClass = Type
	# # static class
	# @createHelper = (childClass) ->
	# 	h = -> new childClass(arguments...)
	# 	h.class = childClass
	# 	h
	constructor: (args, min, max) ->
		@error "Abstract class 'Type' cannot be instantiated directly." if @constructor is Type
		@error "Super needs child type arguments as its first argument." unless arguments.length
		l = args.length
		switch
			when max is undefined
				if min and l < min then @error "#{@constructor.name} must have at least #{min} argument#{s(min)}."
			when min is max
				if min is 0 and l then @error "#{@constructor.name} cannot have any arguments."
				if l isnt min then @error "#{@constructor.name} must have exactly #{min} argument#{s(min)}."
			else
				if l > max then @error "#{@constructor.name} must have at most #{max} argument#{s(max)}."
				if l < min then @error "#{@constructor.name} must have at least #{min} argument#{s(min)}."

	validate: -> false # false if child class valitate missing
	typeName: -> @constructor.name
	error: (msg) -> throw new InvalidTypeError msg


createHelper = (childClass) ->
	h = -> new childClass(arguments...)
	h.rootClass = Type
	h.class = childClass
	h

module.exports = {Type, InvalidTypeError, createHelper}
