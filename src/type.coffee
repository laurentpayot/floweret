CustomType = require './CustomType'
{isType, isAnyType, getTypeName} = require '.'

class Type extends CustomType
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@validator) ->
		super(arguments...)
		@error "'#{@helperName}' argument must be a function." unless @validator?.constructor is Function
	validate: (val) -> @validator(val)
	getTypeName: -> "custom type with validation function '#{@validator}'"
	helperName: "type"

module.exports = CustomType.createHelper(Type)
