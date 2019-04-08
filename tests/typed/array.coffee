import {typed} from '../../dist'

test "init", ->
	Numbers = Array(Number)
	a = typed Numbers, [1, 2, 3]
	expect(a).toEqual([1, 2, 3])

test "init empty array", ->
	Numbers = Array(Number)
	a = typed Numbers, []
	expect(a).toEqual([])

test "set", ->
	Numbers = Array(Number)
	a = typed Numbers, [1, 2, 3]
	a.push(4)
	expect(a).toEqual([1, 2, 3, 4])

test "trow an error with a non-array type", ->
	Numbers = Array(Number)
	expect(-> a = typed Numbers, 1)
	.toThrow("Expected 'array of 'Number'', got Number 1.")

test "trow an error with a mismatched array type", ->
	Numbers = Array(Number)
	expect(-> a = typed Numbers, [1, true, 3])
	.toThrow("Expected an array with element 1 of type 'Number' instead of Boolean true.")

test "trow an error for a push type mismatch", ->
	Numbers = Array(Number)
	a = typed Numbers, [1, 2, 3]
	expect(-> a.push(true))
	.toThrow("Expected an array with element 3 of type 'Number' instead of Boolean true.")

test "trow an error for a set type mismatch", ->
	Numbers = Array(Number)
	a = typed Numbers, [1, 2, 3]
	expect(-> a[1] = true)
	.toThrow("Expected an array with element 1 of type 'Number' instead of Boolean true.")

describe "fn auto-typing", -> # TODO !!!
