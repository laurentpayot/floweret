import isValid from './isValid'
import shouldBe from './shouldBe'
import {InvalidType} from './errors'

proxy = (type, object={}) ->
	(object[key] = proxy(val, object[key])) for key, val of type when val?.constructor is Object
	new Proxy(object,
		set: (o, k, v) ->
			throw new TypeError "Object property #{shouldBe(v, type[k])}." unless isValid(v, type[k])
			o[k] = v
			true # indicate success
	)

export default (type, object={}) ->
	throw new InvalidType "'obj' first argument must be an object type." unless isValid(type, Object)
	throw new InvalidType "'obj' second argument #{shouldBe(object, type)}." unless object?.constructor is Object
	proxy(type, object)
