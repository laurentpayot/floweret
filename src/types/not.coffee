import Type from './Type'
import isValid from '../isValid'
import {isAny, getTypeName} from '../tools'

class Not extends Type
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		Type.warn "Any is inadequate as '#{@helperName}' argument." if isAny(@type)
	validate: (val) -> not isValid(@type, val)
	getTypeName: -> "not '#{getTypeName(@type)}'"
	helperName: "not"

export default Type.createHelper(Not)
