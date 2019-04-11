import Type from './Type'
import isValid from '../isValid'
import {isAny, getTypeName} from '../tools'

class Tuple extends Type
	# 2 or more arguments
	argsMin: 2
	constructor: (@types...) ->
		super(arguments...)
		Type.warn "Use 'Array(#{@types.length})' type instead of a #{@constructor.name}
				of #{@types.length} values of any type'." if @types.every((a) -> isAny(a))
	validate: (val) ->
		return false unless Array.isArray(val) and val.length is @types.length
		val.every((e, i) => isValid(e, @types[i]))
	getTypeName: -> "tuple of #{@types.length} elements '#{(getTypeName(t) for t in @types).join(", ")}'"
	checkWrap: (arr, context) ->
		# NB: skipping parent class validation to let pre-proxy validation find a better error message
		# super(arr, context)
		Type.error(context, arr, @, @alias) unless Array.isArray(arr)
		sizeErrorMessage = "#{if @alias then @alias+' t' else 'T'}uple must have a length of #{@types.length}."
		validator = (a, i, v) =>
			Type.error(sizeErrorMessage) unless i < @types.length
			Type.error((if context then context + ' ' else '') +
						(if @alias then @alias + ' ' else '') +
						"tuple element #{i}", v, @types[i]) unless isValid(v, @types[i])
			a[i] = v
			true # indicate success
		# pre-proxy validation
		validator(arr, index, val) for val, index in arr
		new Proxy(arr,
			set: validator
			deleteProperty: (a, i) -> Type.error(sizeErrorMessage)
		)

export default Type.createHelper(Tuple)
