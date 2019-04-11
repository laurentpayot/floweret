import Type from './Type'

class Constraint extends Type
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@validator) ->
		super(arguments...)
		Type.invalid "'#{@helperName}' argument must be a function." unless @validator?.constructor is Function
	validate: (val) -> @validator(val)
	getTypeName: -> "constrained " +
		if @alias then "type" else "by " + if @validator.name then "function '#{@validator.name}'" else "'#{@validator}'"
	helperName: "constraint"

export default Type.createHelper(Constraint)
