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
	proxy: (arr) ->
		super(arr) # validating instanciation
		new Proxy(arr,
			set: (a, i, v) =>
				unless i < @types.length
					badArray = [a...]
					badArray[i] = v
					Type.error("", badArray, helper(@types...))
				unless isValid(v, @types[i])
					badArray = [a...]
					badArray[i] = v
					Type.error("", badArray, helper(@types...))
				t[i] = v
				true # indicate success
			deleteProperty: (a, i) =>
				badArray = [a...]
				badArray.splice(i, 1)
				Type.error("", badArray, helper(@types...))
		)

helper = Type.createHelper(Tuple)

export default helper
