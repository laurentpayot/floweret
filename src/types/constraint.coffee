import CustomType from './CustomType'

class Constraint extends CustomType
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@validator) ->
		super(arguments...)
		@error "'#{@helperName}' argument must be a function." unless @validator?.constructor is Function
	validate: (val) -> @validator(val)
	getTypeName: -> "constrained by '#{@validator}'"
	helperName: "constraint"

export default CustomType.createHelper(Constraint)
