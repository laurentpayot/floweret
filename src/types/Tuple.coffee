import Type from './Type'
import isValid from '../isValid'
import {isAny, getTypeName} from '../tools'

class Tuple extends Type
	# 2 or more arguments
	argsMin: 2
	constructor: (@types...) ->
		super(arguments...)
		@warn "Use 'Array(#{@types.length})' type instead of a #{@constructor.name}
				of #{@types.length} values of any type'." if @types.every((t) -> isAny(t))
	validate: (val) ->
		return false unless Array.isArray(val) and val.length is @types.length
		val.every((e, i) => isValid(e, @types[i]))
	getTypeName: -> "tuple of #{@types.length} elements '#{(getTypeName(t) for t in @types).join(", ")}'"

export default Type.createHelper(Tuple)
