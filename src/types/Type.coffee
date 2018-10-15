import {InvalidType} from '../errors'

argsNb = (n) -> " #{n} argument#{if n is 1 then '' else 's'}."

export default class Type
	# static  method
	@createHelper: (childClass) ->
		h = -> new childClass(arguments...)
		h.rootClass = Type
		h
	error: (msg) -> throw new InvalidType msg
	warn: (msg) -> console.warn("Floweret type:", msg) unless process?.env.NODE_ENV is 'production'
	argsMin: undefined
	argsMax: undefined
	constructor: ->
		@error "Abstract class 'Type' cannot be instantiated directly." if @constructor is Type
		l = arguments.length
		min = @argsMin
		max = @argsMax
		name = @helperName or @constructor.name
		switch
			when max is undefined
				if min and l < min then @error "'#{name}' must have at least#{argsNb(min)}"
			when min is max
				if min is 0 and l then @error "'#{name}' cannot have any arguments."
				if l isnt min then @error "'#{name}' must have exactly#{argsNb(min)}"
			else
				if l > max then @error "'#{name}' must have at most#{argsNb(max)}"
				if l < min then @error "'#{name}' must have at least#{argsNb(min)}"
	validate: -> false # false if child class validate() missing
	getTypeName: -> @constructor.name
