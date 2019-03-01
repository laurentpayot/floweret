import isValid from '../isValid'
import shouldBe from '../shouldBe'
import {InvalidType} from '../errors'

proxy = (type, arr) ->
	new Proxy(arr,
		set: (a, k, v) ->
			throw new TypeError "Array instance element #{k} #{shouldBe(v, type)}." unless isValid(v, type)
			a[k] = v
			true # indicate success
	)

export default (type, arr) ->
	throw new InvalidType "'array' argument #2 #{shouldBe(arr, Array(type))}." unless isValid(arr, Array(type))
	proxy(type, arr)
