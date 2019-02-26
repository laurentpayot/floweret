import isValid from './isValid'
import shouldBe from './shouldBe'
import {InvalidType} from './errors'

proxy = (type, object={}, path) ->
	(object[key] = proxy(val, object[key], [key, path...])) for key, val of type when val?.constructor is Object
	new Proxy(object,
		set: (o, k, v) ->
			unless isValid(v, type[k])
				pathObject = {"#{k}": v}
				typeObject = {"#{k}": type[k]}
				for p in path
					pathObject = {"#{p}": pathObject}
					typeObject = {"#{p}": typeObject}
				throw new TypeError "Object instance #{shouldBe(pathObject, typeObject)}."
			o[k] = v
			true # indicate success
	)

export default (type, object={}) ->
	throw new InvalidType "'obj' first argument must be an object type." unless isValid(type, Object)
	throw new InvalidType "'obj' second argument #{shouldBe(object, type)}." unless object?.constructor is Object
	proxy(type, object, [])
