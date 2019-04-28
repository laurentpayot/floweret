import isValid from './isValid'
import {isAny} from './tools'
import Type from './types/Type'

objectProxy = (type, obj, aliasName, path=[]) ->
	(obj[key] = objectProxy(val, obj[key], aliasName, [key, path...])) for key, val of type when val?.constructor is Object
	error = (k, v, deletion) ->
		pathObject = if deletion then {} else {"#{k}": v}
		typeObject = {"#{k}": type[k]}
		for p in path
			pathObject = {"#{p}": pathObject}
			typeObject = {"#{p}": typeObject}
		Type.error("", pathObject, typeObject, aliasName)
	new Proxy(obj,
		set: (o, k, v) ->
			error(k, v) unless isValid(type[k], v)
			o[k] = v
			true # indicate success
		deleteProperty: (o, k) ->
			error(k, 0, true) if k of type
			delete o[k]
	)

arrayProxy = (type, arr, aliasName) ->
	new Proxy(arr,
		set: (a, i, v) ->
			unless isValid(type, v)
				badArray = [a...]
				badArray[i] = v
				Type.error("", badArray, [type], aliasName)
			a[i] = v
			true # indicate success
	)

sizedArrayProxy = (arr, aliasName) ->
	new Proxy(arr,
		set: (a, i, v) ->
			unless i < a.length
				badArray = [a...]
				badArray[i] = v
				Type.error("", badArray, Array(arr.length), aliasName)
			a[i] = v
			true # indicate success
		deleteProperty: (a, i) ->
			badArray = [a...]
			badArray.splice(i, 1)
			Type.error("", badArray, Array(arr.length), aliasName)
	)

# NB: `context` string is for instantiation only, do not use post-instantiation in actual proxies
check = (type, val, context="", aliasName="") ->
	Type.warn "Any is not needed as 'check' argument." if not context and isAny(type)
	# custom types first for customized instantiation validity check
	if type instanceof Type or type?.rootClass is Type
		return (if type.rootClass then type() else type).checkWrap(val, context)
	Type.error(context, val, type, aliasName) unless isValid(type, val)
	switch
		when Array.isArray(type)
			switch type.length
				when 1 then arrayProxy(type[0], val, aliasName)
				else
					# checking two first values instead of `Object.values(type).length` for performance reasons
					if type[0] is undefined and type[1] is undefined # array of empty values: sized array, e.g.: `Array(1000)`)
						sizedArrayProxy(val, aliasName)
					else # union of types: typing with the first valid type
						check(type.find((t) -> isValid(t, val)), val, context, aliasName)
		when type?.constructor is Object then objectProxy(type, val, aliasName)
		else val # no proxy

export default check
