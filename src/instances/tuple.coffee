import isValid from '../isValid'
import shouldBe from '../shouldBe'
import {InvalidType} from '../errors'
import Tuple from '../types/Tuple'

export default (types..., tup) ->
	# simply checking for array type to let pre-prox validation find a better error message
	throw new InvalidType "'tuple' argument #2 #{shouldBe(tup, Tuple(types...))}." unless isValid(tup, Array)
	sizeErrorMessage = "Tuple instance must have a length of #{types.length}."
	validator = (t, i, v) ->
		throw new TypeError sizeErrorMessage unless i < types.length
		throw new TypeError "Tuple instance element #{i} #{shouldBe(v, types[i])}." unless isValid(v, types[i])
		t[i] = v
		true # indicate success
	validator(tup, index, val) for val, index in tup
	new Proxy(tup,
		set: validator
		deleteProperty: (t, i) -> throw new TypeError sizeErrorMessage
	)
