import isValid from './isValid'
import typeError from './typeError'
import Type from './types/Type'

objectProxy = (type, obj, context, path=[]) ->
	(obj[key] = objectProxy(val, obj[key], context, [key, path...])) for key, val of type when val?.constructor is Object
	error = (k, v, deletion) ->
		pathObject = if deletion then {} else {"#{k}": v}
		typeObject = {"#{k}": type[k]}
		for p in path
			pathObject = {"#{p}": pathObject}
			typeObject = {"#{p}": typeObject}
		typeError(context, pathObject, typeObject)
	new Proxy(obj,
		set: (o, k, v) ->
			error(k, v) unless isValid(v, type[k])
			o[k] = v
			true # indicate success
		deleteProperty: (o, k) ->
			error(k, 0, true)
	)

arrayProxy = (type, arr, context) ->
	new Proxy(arr,
		set: (a, i, v) ->
			unless isValid(v, type)
				badArray = [a...]
				badArray[i] = v
				typeError(context, badArray, [type])
			a[i] = v
			true # indicate success
	)

sizedArrayProxy = (arr, context) ->
	sizeErrorMessage = "Expected an array with a length of #{arr.length}."
	new Proxy(arr,
		set: (a, i, v) ->
			unless i < a.length
				badArray = [a...]
				badArray[i] = v
				Type.error(context, badArray, Array(arr.length))
			a[i] = v
			true # indicate success
		deleteProperty: (a, i) ->
			badArray = [a...]
			badArray.splice(i, 1)
			Type.error(context, badArray, Array(arr.length))
	)

typed = (type, val, context="") ->
	# custom types first for customized instantiation validity check
	return type.proxy(val, context) if type instanceof Type
	typeError(context, val, type) unless isValid(val, type)
	switch
		when Array.isArray(type)
			switch type.length
				when 1 then arrayProxy(type[0], val, context)
				else
					# checking two first values instead of `Object.values(type).length` for performance reasons
					if type[0] is undefined and type[1] is undefined # array of empty values: sized array, e.g.: `Array(1000)`)
						sizedArrayProxy(val ,context)
					else # union of types: typing with the first valid type
						typed(type.find((t) -> isValid(val, t)), val, context)
		when type?.constructor is Object then objectProxy(type, val, context)
		else val # no proxy

export default typed
