# NB: to avoid circular dependencies, error static method is added to Type class in `typeError` file
# import typeError from '../typeError'

class InvalidType extends Error
	name: 'InvalidType'

argsNb = (n) -> " #{n} argument#{if n is 1 then '' else 's'}."

export default class Type
	# static  methods
	@createHelper: (childClass) ->
		h = -> new childClass(arguments...)
		h.rootClass = Type
		h
	@invalid: (msg) -> throw new InvalidType msg
	invalid: Type.invalid
	warn: (msg) -> console.warn("Floweret type:", msg) unless process?.env.NODE_ENV is 'production'
	argsMin: undefined
	argsMax: undefined
	constructor: ->
		@invalid "Abstract class 'Type' cannot be instantiated directly." if @constructor is Type
		l = arguments.length
		min = @argsMin
		max = @argsMax
		name = @helperName or @constructor.name
		switch
			when max is undefined
				if min and l < min then @invalid "'#{name}' must have at least#{argsNb(min)}"
			when min is max
				if min is 0 and l then @invalid "'#{name}' cannot have any arguments."
				if l isnt min then @invalid "'#{name}' must have exactly#{argsNb(min)}"
			else
				if l > max then @invalid "'#{name}' must have at most#{argsNb(max)}"
				if l < min then @invalid "'#{name}' must have at least#{argsNb(min)}"
	validate: -> false # false if child class validate() missing
	getTypeName: -> @constructor.name
	# NB: to avoid circular dependencies, error static method is added to Type class in `typeError` file
	proxy: (val) -> if @validate(val) then val else Type.error("Instance", val, @)
