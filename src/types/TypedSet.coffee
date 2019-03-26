import Type from './Type'
import isValid from '../isValid'
import {isAny, isLiteral, getTypeName} from '../tools'

class TypedSet extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@invalid "You cannot have #{getTypeName(@type)} as '#{@constructor.name}' argument." if isLiteral(@type)
		@warn "Use 'Set' type instead of a #{@constructor.name} with elements of any type." if isAny(@type)
	validate: (val) -> switch
		when val?.constructor isnt Set then false
		when isAny(@type) then true
		else [val...].every((e) => isValid(e, @type))
	getTypeName: -> "set of '#{getTypeName(@type)}'"

export default Type.createHelper(TypedSet)
