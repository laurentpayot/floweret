import isValid from '../isValid'
import shouldBe from '../shouldBe'
import {InvalidType} from '../errors'
import Tuple from '../types/Tuple'

export default (types..., tup) ->
	throw new InvalidType "'tuple' last argument #{shouldBe(tup, Tuple(types...))}." unless isValid(tup, Tuple(types...))
	sizeErrorMessage = "Tuple instance must have a length of #{types.length}."
	new Proxy(tup,
		set: (t, k, v) ->
			throw new TypeError sizeErrorMessage unless k < types.length
			throw new TypeError "Tuple instance element #{k} #{shouldBe(v, types[k])}." unless isValid(v, types[k])
			t[k] = v
			true # indicate success
		deleteProperty: (t, k) -> throw new TypeError sizeErrorMessage
	)
