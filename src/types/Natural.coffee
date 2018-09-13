{InvalidTypeError, createHelper} = require '.'
Integer = require './Integer'

class Natural extends Integer.class
	constructor: (n1, n2) ->
		super(n1, n2)
		throw new InvalidTypeError "#{@constructor.name} arguments must be positive integers." if n1 < 0 or n2 < 0
	validate: (val) ->
		super(val) and val >= 0

module.exports = createHelper(Natural)

