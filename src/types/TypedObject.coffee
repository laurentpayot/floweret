import CustomType from './CustomType'
import isType from '../isType'
import {isAnyType, getTypeName} from '../tools'

class TypedObject extends CustomType
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@warn "Use 'Object' type instead of a #{@constructor.name} with values of any type." if isAnyType(@type)
	validate: (val) ->
		return false unless val?.constructor is Object
		return true if isAnyType(@type)
		Object.values(val).every((v) => isType(v, @type))
	getTypeName: -> "object with values of type '#{getTypeName(@type)}'"

export default CustomType.createHelper(TypedObject)
