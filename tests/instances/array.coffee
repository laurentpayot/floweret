import {instance} from '../../dist'

test "init", ->
	Numbers = Array(Number)
	a = instance Numbers, [1, 2, 3]
	expect(a).toEqual([1, 2, 3])

test "set", ->
	Numbers = Array(Number)
	a = instance Numbers, [1, 2, 3]
	a.push(4)
	expect(a).toEqual([1, 2, 3, 4])

test "trow an error with a non-array type", ->
	Numbers = Array(Number)
	expect(-> a = instance Numbers, 1)
	.toThrow("Instance should be of type 'array of 'Number'' instead of Number 1.")

test "trow an error with a mismatched array type", ->
	Numbers = Array(Number)
	expect(-> a = instance Numbers, [1, true, 3])
	.toThrow("Instance should be an array with element 1 of type 'Number' instead of Boolean true.")

test "trow an error for a push type mismatch", ->
	Numbers = Array(Number)
	a = instance Numbers, [1, 2, 3]
	expect(-> a.push(true))
	.toThrow("Array instance element 3 should be of type 'Number' instead of Boolean true.")

test "trow an error for a set type mismatch", ->
	Numbers = Array(Number)
	a = instance Numbers, [1, 2, 3]
	expect(-> a[1] = true)
	.toThrow("Array instance element 1 should be of type 'Number' instead of Boolean true.")
