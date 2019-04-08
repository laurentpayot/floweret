import {typed} from '../../dist'

test "init", ->
	Trio = Array(3)
	a = typed Trio, [1, true, 'three']
	expect(a).toEqual([1, true, 'three'])

test "set", ->
	Trio = Array(3)
	a = typed Trio, [1, true, 'three']
	a[1] = 2
	expect(a).toEqual([1, 2, 'three'])

test "trow an error with a non-array type", ->
	Trio = Array(3)
	expect(-> a = typed Trio, 1)
	.toThrow("Expected 'array of 3 elements', got Number 1.")

test "trow an error with a too long array", ->
	Trio = Array(3)
	expect(-> a = typed Trio, [1, true, 3, 4])
	.toThrow("Expected an array with a length of 3 instead of 4.")

test "trow an error with a too short array", ->
	Trio = Array(3)
	expect(-> a = typed Trio, [1, true])
	.toThrow("Expected an array with a length of 3 instead of 2.")

test "trow an error after a push", ->
	Trio = Array(3)
	a = typed Trio, [1, true, 'three']
	expect(-> a.push(4))
	.toThrow("Expected an array with a length of 3 instead of 4.")

test "trow an error after a pop", ->
	Trio = Array(3)
	a = typed Trio, [1, true, 'three']
	expect(-> a.pop())
	.toThrow("Expected an array with a length of 3 instead of 2.")

describe.skip "Size 1", ->

	test "init", ->
		Mono = Array(1)
		a = typed Mono, [1]
		expect(a).toEqual([1])

	test "set", ->
		Mono = Array(1)
		a = typed Mono, [1]
		a[0] = 2
		expect(a).toEqual([2])

	test "trow an error with a non-array type", ->
		Mono = Array(1)
		expect(-> a = typed Mono, 1)
		.toThrow("Expected of type 'array of 1 elements, got Number 1.")

	test "trow an error with a too long array", ->
		Mono = Array(1)
		expect(-> a = typed Mono, [1, true])
		.toThrow("Expected an array with a length of 1 instead of 2.")

	test "trow an error with a too short array", ->
		Mono = Array(1)
		expect(-> a = typed Mono, [])
		.toThrow("Expected an array with a length of 1 instead of 0.")

	test "trow an error after a push", ->
		Mono = Array(1)
		a = typed Mono, [1]
		expect(-> a.push(2))
		.toThrow("Sized array must have a length of 1.")

	test "trow an error after a pop", ->
		Mono = Array(1)
		a = typed Mono, [1]
		expect(-> a.pop())
		.toThrow("Sized array must have a length of 1.")

describe "fn auto-typing", -> # TODO !!!
