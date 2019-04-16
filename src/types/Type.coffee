# NB: to avoid circular dependencies, error static method is added to Type class in `typeError` file
# import typeError from '../typeError'

class InvalidType extends Error
	name: 'InvalidType'

argsNb = (n) -> " #{n} argument#{if n is 1 then '' else 's'}."

export default class Type
	# static  methods
	@createHelper: (childClass) ->
		h = -> new childClass(arguments...)
		h.rootClass = Type # function attribute used to detect helper
		h
	@invalid: (msg) -> throw new InvalidType msg
	@warn: (msg) -> console.warn("Floweret:", msg) unless process?.env.NODE_ENV is 'production'
	argsMin: undefined
	argsMax: undefined
	constructor: ->
		Type.invalid "Abstract class 'Type' cannot be instantiated directly." if @constructor is Type
		l = arguments.length
		min = @argsMin
		max = @argsMax
		name = @helperName or @constructor.name
		switch
			when max is undefined
				if min and l < min then Type.invalid "'#{name}' must have at least#{argsNb(min)}"
			when min is max
				if min is 0 and l then Type.invalid "'#{name}' cannot have any arguments."
				if l isnt min then Type.invalid "'#{name}' must have exactly#{argsNb(min)}"
			else
				if l > max then Type.invalid "'#{name}' must have at most#{argsNb(max)}"
				if l < min then Type.invalid "'#{name}' must have at least#{argsNb(min)}"
	validate: -> false # false if child class validate method missing
	getTypeName: -> @constructor.name
	aliasName: ""
	alias: (name) ->
		Type.error("Alias name must be a non-empty string.") unless typeof name is 'string' and name
		@aliasName = name
		@ # returning the instance
	# NB: to avoid circular dependencies, error static method is added to Type class in `typeError` file
	checkWrap: (val, context) -> if @validate(val) then val else Type.error(context, val, @, @aliasName)
