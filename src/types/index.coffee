class InvalidTypeError extends Error
	constructor: (msg) -> super("Invalid type: " + msg)

s = (n) -> if n is 1 then '' else 's'

class Type
	# static methods
	@error: (msg) -> throw new InvalidTypeError msg
	@createHelper: (childClass) ->
		h = -> new childClass(arguments...)
		h.rootClass = Type
		h
	constructor: (args, min, max) ->
		Type.error "Abstract class 'Type' cannot be instantiated directly." if @constructor is Type
		Type.error "Super needs child type arguments as its first argument." unless arguments.length
		l = args.length
		name = @helperName or @constructor.name
		switch
			when max is undefined
				if min and l < min then Type.error "'#{name}' must have at least #{min} argument#{s(min)}."
			when min is max
				if min is 0 and l then Type.error "'#{name}' cannot have any arguments."
				if l isnt min then Type.error "'#{name}' must have exactly #{min} argument#{s(min)}."
			else
				if l > max then Type.error "'#{name}' must have at most #{max} argument#{s(max)}."
				if l < min then Type.error "'#{name}' must have at least #{min} argument#{s(min)}."
	validate: -> false # false if child class valitate missing
	getTypeName: -> @constructor.name


module.exports = Type
