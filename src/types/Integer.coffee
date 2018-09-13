{Type, InvalidTypeError, createHelper} = require '.'

class Integer extends Type
	min = undefined
	max = undefined
	constructor: (n1, n2) ->
		super(arguments, 0, 2) # up to 2 arguments
		throw new InvalidTypeError "#{@constructor.name} arguments must be numbers." \
			unless typeof n1 in ['undefined', 'number'] and typeof n2 in ['undefined', 'number']
		if arguments.length is 1
			@max = n1
		else
			throw new InvalidTypeError "#{@constructor.name} max value cannot be less than min value." if n2 < n1
			[@min, @max] = [n1, n2]
	validate: (val) ->
		return false unless typeof val is 'number'
		return false unless val % 1 is 0
		return false if @max isnt undefined and val > max
		return false if @min isnt undefined and val < min
		true

module.exports = createHelper(Integer)

