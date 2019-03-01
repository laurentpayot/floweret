import isValid from '../isValid'
import shouldBe from '../shouldBe'
import {InvalidType} from '../errors'

proxy = (type, obj, path) ->
	(obj[key] = proxy(val, obj[key], [key, path...])) for key, val of type when val?.constructor is Object
	new Proxy(obj,
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

export default (type, obj) ->
	throw new InvalidType "'object' argument #1 must be an Object type." unless isValid(type, Object)
	throw new InvalidType "'object' argument #2 #{shouldBe(obj, type)}." unless isValid(obj, Object)
	proxy(type, obj, [])
