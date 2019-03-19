import {array} from '../src'

test "init", ->
	a = array Number, [1, 2, 3]
	expect(a).toEqual([1, 2, 3])

test "set", ->
	a = array Number, [1, 2, 3]
	a.push(4)
	expect(a).toEqual([1, 2, 3, 4])

test "trow an error with a non-array type", ->
	expect(-> a = array Number, 1)
	.toThrow("'array' argument #2 should be of type 'array of 'Number'' instead of Number 1.")

test "trow an error with a mismatched array type", ->
	expect(-> a = array Number, [1, true, 3])
	.toThrow("'array' argument #2 should be an array with element 1 of type 'Number'
				instead of Boolean true.")

test "trow an error for a push type mismatch", ->
	a = array Number, [1, 2, 3]
	expect(-> a.push(true))
	.toThrow("Array instance element 3 should be of type 'Number' instead of Boolean true.")

test "trow an error for a set type mismatch", ->
	a = array Number, [1, 2, 3]
	expect(-> a[1] = true)
	.toThrow("Array instance element 1 should be of type 'Number' instead of Boolean true.")
