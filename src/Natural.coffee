import CustomType from './CustomType'
import IntegerHelper from './Integer'

Integer = IntegerHelper().constructor

class Natural extends Integer
	constructor: (n1, n2) ->
		super(arguments...)
		@error "'#{@constructor.name}' arguments must be positive numbers." if n1 < 0 # Integer ensures n2 >= n1
	validate: (val) -> super(val) and val >= 0

export default CustomType.createHelper(Natural)
