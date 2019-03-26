import Type from './Type'

class SizedString extends Type
	min: undefined
	max: undefined
	# 1 or 2 arguments
	argsMin: 1
	argsMax: 2
	constructor: (n1, n2) ->
		super(arguments...)
		Type.invalid "'#{@constructor.name}' arguments must be positive integers." \
			unless (n1 is undefined or Number.isInteger(n1) and n1 >= 0) \
				and (n2 is undefined or Number.isInteger(n2) and n2 >= 0)
		if arguments.length is 1
			@max = n1
		else
			Type.invalid "'#{@constructor.name}' max value cannot be less than min value." if n2 < n1
			# [@min, @max] = [n1, n2] # problem with Rollup commonjs plugin
			@min = n1
			@max = n2
	validate: (val) ->
		typeof val is 'string' and (@max is undefined or val.length <= @max) and (@min is undefined or val.length >= @min)
	getTypeName: ->
		max = if @max? then " of at most #{@max} characters" else ''
		min = if @min? then " of at least #{@min} characters" else ''
		"#{@constructor.name}#{min}#{if min and max then ' and' else ''}#{max}"

export default Type.createHelper(SizedString)

