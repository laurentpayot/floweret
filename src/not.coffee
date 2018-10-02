CustomType = require './CustomType'
{isType, isAnyType, getTypeName} = require '.'

class Not extends CustomType
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@warn "AnyType is inadequate as '#{@helperName}' argument." if isAnyType(@type)
	validate: (val) -> not isType(val, @type)
	getTypeName: -> "not '#{getTypeName(@type)}'"
	helperName: "not"

module.exports = CustomType.createHelper(Not)
