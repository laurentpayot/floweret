import isValid from './isValid'
import typeError from './typeError'
import Type from './types/Type'

objectProxy = (type, obj, alias, path=[]) ->
	(obj[key] = objectProxy(val, obj[key], alias, [key, path...])) for key, val of type when val?.constructor is Object
	error = (k, v, deletion) ->
		pathObject = if deletion then {} else {"#{k}": v}
		typeObject = {"#{k}": type[k]}
		for p in path
			pathObject = {"#{p}": pathObject}
			typeObject = {"#{p}": typeObject}
		typeError("", pathObject, typeObject, alias)
	new Proxy(obj,
		set: (o, k, v) ->
			error(k, v) unless isValid(v, type[k])
			o[k] = v
			true # indicate success
		deleteProperty: (o, k) ->
			error(k, 0, true) if k of type
			delete o[k]
	)

arrayProxy = (type, arr, alias) ->
	new Proxy(arr,
		set: (a, i, v) ->
			unless isValid(v, type)
				badArray = [a...]
				badArray[i] = v
				typeError("", badArray, [type], alias)
			a[i] = v
			true # indicate success
	)

sizedArrayProxy = (arr) ->
	sizeErrorMessage = "Expected an array with a length of #{arr.length}."
	new Proxy(arr,
		set: (a, i, v) ->
			unless i < a.length
				badArray = [a...]
				badArray[i] = v
				Type.error("", badArray, Array(arr.length))
			a[i] = v
			true # indicate success
		deleteProperty: (a, i) ->
			badArray = [a...]
			badArray.splice(i, 1)
			Type.error("", badArray, Array(arr.length))
	)

# NB: `context` string is for instantiation only, do not use post-instantiation in actual proxies
check = (type, val, context="", alias="") ->
	# custom types first for customized instantiation validity check
	return type.checkWrap(val, context) if type instanceof Type
	typeError(context, val, type, alias) unless isValid(val, type)
	switch
		when Array.isArray(type)
			switch type.length
				when 1 then arrayProxy(type[0], val, alias)
				else
					# checking two first values instead of `Object.values(type).length` for performance reasons
					if type[0] is undefined and type[1] is undefined # array of empty values: sized array, e.g.: `Array(1000)`)
						sizedArrayProxy(val, alias)
					else # union of types: typing with the first valid type
						check(type.find((t) -> isValid(val, t)), val, context, alias)
		when type?.constructor is Object then objectProxy(type, val, alias)
		else val # no proxy

export default check
