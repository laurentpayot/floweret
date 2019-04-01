import typeError from './typeError'
import {isAny} from './tools'
import isValid from './isValid'
import EtcHelper from './types/etc'
import typed from './typed'

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
				for arg, j in args[i..]
					typedArgs[i+j] = if noType then arg else typed(t, arg, "argument ##{i+j+1}")
			else
				if isAny(type)
					typedArgs[i] = args[i]
				else
					if args[i] is undefined
						typeError("Missing required argument number #{i+1}.") unless isValid(undefined, type)
						typedArgs[i] = undefined
					else
						typedArgs[i] = typed(type, args[i], "argument ##{i+1}")
		typeError("Too many arguments provided.") if args.length > argTypes.length and not rest
		if resType instanceof Promise
			# NB: not using `await` because CS would transpile the returned function as an async one
			resType.then((promiseType) ->
				promise = f(typedArgs...)
				typeError("result", promise, promiseType, true) unless promise instanceof Promise
				promise.then((result) -> typed(promiseType, result, "promise result"))
			)
		else
			typed(resType, f(typedArgs...), "result")
