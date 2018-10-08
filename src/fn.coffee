import {InvalidSignature, TypeMismatch} from './errors'
import {isAnyType, getTypeName, typeValue} from './tools'
import isValid from './isValid'
import Type from './types/Type'
import EtcHelper from './types/etc'

Etc = EtcHelper().constructor

error = (msg) -> throw new TypeMismatch msg

# returns a list of keys path to the mismatched type + value not maching + type not matching
badPath = (obj, typeObj) ->
	for k, t of typeObj
		if not isValid(obj[k], t)
			return [k].concat(if obj[k]?.constructor is Object then badPath(obj[k], typeObj[k]) \
								else [obj[k], typeObj[k]])

# type error message comparison part helper
shouldBe = (val, type, promised=false) ->
	apo = if promised then "a promise of " else ''
	"should be " + switch
		when Array.isArray(val) and Array.isArray(type) and (type.length is 1 or not Object.values(type).length)
			if not Object.values(type).length # sized array
				"#{apo}an array with a length of #{type.length} instead of #{val.length}"
			else
				i = val.findIndex((e) -> not isValid(e, type[0]))
				"#{apo}an array with element #{i} of type '#{getTypeName(type[0])}' instead of #{typeValue(val[i])}"
		when val?.constructor is Object and type?.constructor is Object
			[bp..., bv, bt] = badPath(val, type)
			"#{apo}an object with key '#{bp.join('.')}' of type '#{getTypeName(bt)}' instead of #{typeValue(bv)}"
		else
			"#{apo or 'of type '}'#{getTypeName(type)}' instead of #{typeValue(val)}"

# wraps a function to check its arguments types and result type
export default (argTypes..., resType, f) ->
	throw new InvalidSignature "Result type is missing." if resType instanceof Function and not resType.name
	throw new InvalidSignature "Function to wrap is missing." unless f instanceof Function and not f.name
	throw new InvalidSignature "Arguments types are missing." unless argTypes.length
	(args...) -> # returns an unfortunately anonymous function
		rest = false
		for type, i in argTypes
			if type is EtcHelper or type instanceof Etc # rest type
				throw new InvalidSignature "Rest type must be the last of the arguments types." if i+1 < argTypes.length
				rest = true
				t = (if type is EtcHelper then type() else type).type # using default helper parameters
				unless isAnyType(t)
					for arg, j in args[i..]
						error "Argument ##{i+j+1} #{shouldBe(arg, t)}." unless isValid(arg, t)
			else
				unless isAnyType(type)
					if args[i] is undefined
						error "Missing required argument number #{i+1}." unless isValid(undefined, type)
					else
						error "Argument ##{i+1} #{shouldBe(args[i], type)}." unless isValid(args[i], type)
		error "Too many arguments provided." if args.length > argTypes.length and not rest
		if resType instanceof Promise
			# NB: not using `await` because CS would transpile the returned function as an async one
			resType.then((promiseType) ->
				promise = f(args...)
				error "Result #{shouldBe(promise, promiseType, true)}." unless promise instanceof Promise
				promise.then((result) ->
					error "Promise result #{shouldBe(result, promiseType)}." unless isValid(result, promiseType)
					result
				)
			)
		else
			result = f(args...)
			error "Result #{shouldBe(result, resType)}." unless isValid(result, resType)
			result
