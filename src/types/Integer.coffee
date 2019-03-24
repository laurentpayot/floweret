import Type from './Type'

class Integer extends Type
	min: undefined
	max: undefined
	# up to 2 arguments
	argsMin: 0
	argsMax: 2
	constructor: (n1, n2) ->
		super(arguments...)
		@error "'#{@constructor.name}' arguments must be numbers." \
			unless typeof n1 in ['undefined', 'number'] and typeof n2 in ['undefined', 'number']
		if arguments.length is 1
			@error "'#{@constructor.name}' max value used alone cannot be negative." if n1 < 0
			@min = 0
			@max = n1
		else
			@error "'#{@constructor.name}' max value cannot be less than min value." if n2 < n1
			# [@min, @max] = [n1, n2] # problem with Rollup commonjs plugin
			@min = n1
			@max = n2
	validate: (val) -> Number.isInteger(val) and (@max is undefined or val <= @max) and (@min is undefined or val >= @min)
	getTypeName: ->
		etoet = "er than or equal to "
		max = if @max? then " small" + etoet + @max else ''
		min = if @min? then " bigg" + etoet + @min else ''
		@constructor.name + min + (if min and max then " and" else '') + max

export default Type.createHelper(Integer)

