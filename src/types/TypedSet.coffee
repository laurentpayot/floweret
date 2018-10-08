import Type from './Type'
import isValid from '../isValid'
import {isAnyType, isLiteral, getTypeName} from '../tools'

class TypedSet extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@error "You cannot have #{getTypeName(@type)} as '#{@constructor.name}' argument." if isLiteral(@type)
		@warn "Use 'Set' type instead of a #{@constructor.name} with elements of any type." if isAnyType(@type)
	validate: (val) ->
		return false unless val?.constructor is Set
		return true if isAnyType(@type)
		[val...].every((e) => isValid(e, @type))
	getTypeName: -> "set of '#{getTypeName(@type)}'"

export default Type.createHelper(TypedSet)
