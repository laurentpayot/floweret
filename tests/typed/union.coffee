import {typed} from '../../dist'

describe "Union", ->

	test "init", ->
		Numbers = Array(Number)
		n = typed [Number, Numbers, String], [1, 2, 3]
		expect(n).toEqual([1, 2, 3])

	test "init empty array", ->
		Numbers = Array(Number)
		n = typed [Number, Numbers, String], []
		expect(n).toEqual([])

	test "set", ->
		Numbers = Array(Number)
		n = typed [Number, Numbers, String], [1, 2, 3]
		n.push(4)
		expect(n).toEqual([1, 2, 3, 4])

	test "trow an error with a non-array type", ->
		Numbers = Array(Number)
		expect(-> n = typed [Number, Numbers, String], true)
		.toThrow("Expected Number or 'array of 'Number'' or String, got Boolean true.")

	test "trow an error with a mismatched array type", ->
		Numbers = Array(Number)
		expect(-> n = typed [Number, Numbers, String], [1, true, 3])
		.toThrow("Expected Number or 'array of 'Number'' or String, got Array of 3 elements.")

	test "trow an error for a push type mismatch", ->
		Numbers = Array(Number)
		n = typed [Number, Numbers, String], [1, 2, 3]
		expect(-> n.push(true))
		.toThrow("Expected an array with element 3 of type 'Number' instead of Boolean true.")

	test "trow an error for a set type mismatch", ->
		Numbers = Array(Number)
		n = typed [Number, Numbers, String], [1, 2, 3]
		expect(-> n[1] = true)
		.toThrow("Expected an array with element 1 of type 'Number' instead of Boolean true.")
