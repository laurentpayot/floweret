import CustomType from './CustomType'
import {isType, isAnyType, getTypeName} from '..'

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

export default CustomType.createHelper(Not)
