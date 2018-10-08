import Type from './Type'
import isType from '../isType'
import {isAnyType, getTypeName} from '../tools'

class Not extends Type
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@warn "AnyType is inadequate as '#{@helperName}' argument." if isAnyType(@type)
	validate: (val) -> not isType(val, @type)
	getTypeName: -> "not '#{getTypeName(@type)}'"
	helperName: "not"

export default Type.createHelper(Not)
