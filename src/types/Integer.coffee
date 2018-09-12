{Type, InvalidTypeError, createHelper} = require '.'

class Integer extends Type
	min = undefined
	max = undefined
	constructor: (n1, n2) ->
		super() # needed
		throw new InvalidTypeError "#{@constructor.name} arguments must be numbers." \
			unless typeof n1 in ['undefined', 'number'] and typeof n2 in ['undefined', 'number']
		switch arguments.length
			when 0 then # nothing
			when 1 then @max = n1
			when 2
				throw new InvalidTypeError "#{@constructor.name} max value
											cannot be less than min value." if n2 < n1
				[@min, @max] = [n1, n2]
			else throw new InvalidTypeError "#{@constructor.name} must have
											at most two arguments." if arguments.length > 2
	validate: (val) ->
		return false unless typeof val is 'number'
		return false unless val % 1 is 0
		return false if @max isnt undefined and val > max
		return false if @min isnt undefined and val < min
		true

# truthy second argument to allow Integer to be used as a function
module.exports = createHelper(Integer, true)

