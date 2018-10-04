import CustomType from './CustomType'
import isType from '../isType'
import {isAnyType, getTypeName} from '../tools'

class Tuple extends CustomType
	# 2 or more arguments
	argsMin: 2
	constructor: (@types...) ->
		super(arguments...)
		@warn "Use 'Array(#{@types.length})' type instead of a #{@constructor.name}
				of #{@types.length} values of any type'." if @types.every((t) -> isAnyType(t))
	validate: (val) ->
		return false unless Array.isArray(val) and val.length is @types.length
		val.every((e, i) => isType(e, @types[i]))
	getTypeName: -> "tuple of #{@types.length} elements '#{(getTypeName(t) for t in @types).join(", ")}'"

export default CustomType.createHelper(Tuple)
