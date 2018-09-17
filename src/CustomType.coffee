class InvalidTypeError extends Error
	constructor: (msg) -> super("Invalid type: " + msg)

s = (n) -> if n is 1 then '' else 's'

class CustomType
	# static methods
	@error: (msg) -> throw new InvalidTypeError msg
	@warn: (msg) -> console.warn msg unless process?.env.NODE_ENV is 'production'
	@createHelper: (childClass) ->
		h = -> new childClass(arguments...)
		h.rootClass = CustomType
		h
	constructor: (args, min, max) ->
		CustomType.error "Abstract class 'CustomType' cannot be instantiated directly." if @constructor is CustomType
		CustomType.error "Super needs child type arguments as its first argument." unless arguments.length
		l = args.length
		name = @helperName or @constructor.name
		switch
			when max is undefined
				if min and l < min then CustomType.error "'#{name}' must have at least #{min} argument#{s(min)}."
			when min is max
				if min is 0 and l then CustomType.error "'#{name}' cannot have any arguments."
				if l isnt min then CustomType.error "'#{name}' must have exactly #{min} argument#{s(min)}."
			else
				if l > max then CustomType.error "'#{name}' must have at most #{max} argument#{s(max)}."
				if l < min then CustomType.error "'#{name}' must have at least #{min} argument#{s(min)}."
	validate: -> false # false if child class valitate missing
	getTypeName: -> @constructor.name


module.exports = CustomType
