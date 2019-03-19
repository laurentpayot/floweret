import Type from './Type'
import isValid from '../isValid'
import {isAny, getTypeName} from '../tools'

class TypedObject extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@warn "Use 'Object' type instead of a #{@constructor.name} with values of any type." if isAny(@type)
	validate: (val) -> switch
		when val?.constructor isnt Object then false
		when isAny(@type) then true
		else Object.values(val).every((v) => isValid(v, @type))
	getTypeName: -> "object with values of type '#{getTypeName(@type)}'"

export default Type.createHelper(TypedObject)
