CustomType = require './CustomType'

class Integer extends CustomType
	min = undefined
	max = undefined
	constructor: (n1, n2) ->
		super(arguments, 0, 2) # up to 2 arguments
		CustomType.error "'#{@constructor.name}' arguments must be numbers." \
			unless typeof n1 in ['undefined', 'number'] and typeof n2 in ['undefined', 'number']
		if arguments.length is 1
			@max = n1
		else
			CustomType.error "'#{@constructor.name}' max value cannot be less than min value." if n2 < n1
			[@min, @max] = [n1, n2]
	validate: (val) -> not (typeof val isnt 'number' or val % 1 isnt 0 \
							or @max isnt undefined and val > max or @min isnt undefined and val < min)

module.exports = CustomType.createHelper(Integer)

