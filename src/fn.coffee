import {InvalidSignature} from './errors'
import shouldBe from './shouldBe'
import {isAny} from './tools'
import isValid from './isValid'
import EtcHelper from './types/etc'

Etc = EtcHelper().constructor

error = (msg) -> throw new TypeError msg

# wraps a function to check its arguments types and result type
export default (argTypes..., resType, f) ->
	throw new InvalidSignature "Result type is missing." if resType instanceof Function and not resType.name
	throw new InvalidSignature "Function to wrap is missing." unless f instanceof Function and not f.name
	(args...) -> # returns an unfortunately anonymous function
		rest = false
		for type, i in argTypes
			if type is EtcHelper or type instanceof Etc # rest type
				throw new InvalidSignature "Rest type must be the last of the arguments types." if i+1 < argTypes.length
				rest = true
				t = (if type is EtcHelper then type() else type).type # using default helper parameters
				unless isAny(t)
					for arg, j in args[i..]
						error "Argument ##{i+j+1} #{shouldBe(arg, t)}." unless isValid(arg, t)
			else
				unless isAny(type)
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
