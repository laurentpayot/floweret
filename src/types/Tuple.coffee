import Type from './Type'
import isValid from '../isValid'
import {isAny, getTypeName} from '../tools'

class Tuple extends Type
	# 2 or more arguments
	argsMin: 2
	constructor: (@types...) ->
		super(arguments...)
		Type.warn "Use 'Array(#{@types.length})' type instead of a #{@constructor.name}
				of #{@types.length} values of any type'." if @types.every((t) -> isAny(t))
	validate: (val) ->
		return false unless Array.isArray(val) and val.length is @types.length
		val.every((e, i) => isValid(e, @types[i]))
	getTypeName: -> "tuple of #{@types.length} elements '#{(getTypeName(t) for t in @types).join(", ")}'"
	proxy: (tup) ->
		# NB: skipping parent class validation to let pre-proxy validation find a better error message
		# super(tup)
		Type.error("Instance", tup, @) unless Array.isArray(tup)
		sizeErrorMessage = "Tuple instance must have a length of #{@types.length}."
		validator = (t, i, v) =>
			Type.error(sizeErrorMessage) unless i < @types.length
			Type.error("Tuple instance element #{i}", v, @types[i]) unless isValid(v, @types[i])
			t[i] = v
			true # indicate success
		# pre-proxy validation
		validator(tup, index, val) for val, index in tup
		new Proxy(tup,
			set: validator
			deleteProperty: (t, i) -> Type.error(sizeErrorMessage)
		)

export default Type.createHelper(Tuple)
