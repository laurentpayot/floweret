{Type} = require '.'
IntegerHelper = require './Integer'

Integer = IntegerHelper().constructor

class Natural extends Integer
	constructor: (n1, n2) ->
		super(n1, n2)
		@error "#{@constructor.name} arguments must be positive integers." if n1 < 0 or n2 < 0
	validate: (val) ->
		super(val) and val >= 0

module.exports = Type.createHelper(Natural)