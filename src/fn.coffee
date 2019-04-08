import typeError from './typeError'
import {isAny} from './tools'
import isValid from './isValid'
import EtcHelper from './types/etc'
import check from './check'

Etc = EtcHelper().constructor

class InvalidSignature extends Error
	name: 'InvalidSignature'

# wraps a function to check its arguments types and result type
export default (argTypes..., resType, f) ->
	throw new InvalidSignature "Result type is missing." if resType instanceof Function and not resType.name
	throw new InvalidSignature "Function to wrap is missing." unless f instanceof Function and not f.name
	(args...) -> # returns an unfortunately anonymous function
		rest = false
		typedArgs = []
		for type, i in argTypes
			if type is EtcHelper or type instanceof Etc # rest type
				throw new InvalidSignature "Rest type must be the last of the arguments types." if i+1 < argTypes.length
				rest = true
				t = (if type is EtcHelper then type() else type).type # using default helper parameters
				noType = isAny(t)
				typedArgs.push(if noType then arg else check(t, arg, "argument ##{i+j+1}")) for arg, j in args[i..]
			else
				typedArgs.push(if isAny(type) then args[i] else check(type, args[i], "argument ##{i+1}"))
		typeError("Too many arguments provided.") if args.length > argTypes.length and not rest
		if resType instanceof Promise
			# NB: not using `await` because CS would transpile the returned function as an async one
			resType.then((promiseType) ->
				promise = f(typedArgs...)
				typeError("result", promise, promiseType, true) unless promise instanceof Promise
				promise.then((result) -> check(promiseType, result, "promise result"))
			)
		else
			check(resType, f(typedArgs...), "result")
