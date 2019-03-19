import {isValid} from '../../src'
import {VALUES} from '../fixtures'

describe "Native type elements", ->

	test "return false when value is not an array", ->
		expect(isValid(val, Array(Number))).toBe(false) for val in VALUES when not Array.isArray(val)
		expect(isValid(val, Array(String))).toBe(false) for val in VALUES when not Array.isArray(val)

	test "return true for an array of numbers", ->
		expect(isValid([1, 2, 3], Array(Number))).toBe(true)
		expect(isValid([1], Array(Number))).toBe(true)
		expect(isValid([], Array(Number))).toBe(true)

	test "return true for an array of strings", ->
		expect(isValid(["foo", "bar", "baz"], Array(String))).toBe(true)
		expect(isValid(["foo"], Array(String))).toBe(true)
		expect(isValid([], Array(String))).toBe(true)

	test "return false when an element of the array is not a number", ->
		expect(isValid([1, val, 3], Array(Number))).toBe(false) for val in VALUES when typeof val isnt 'number'
		expect(isValid([val], Array(Number))).toBe(false) for val in VALUES when typeof val isnt 'number'

	# TODO: test typed array optimizations

	test "return false when an element of the array is not a string", ->
		expect(isValid(["foo", val, "bar"], Array(String))).toBe(false) \
			for val in VALUES when typeof val isnt 'string'
		expect(isValid([val], Array(String))).toBe(false) \
			for val in VALUES when typeof val isnt 'string'

describe "Object type elements", ->

	test "return false when value is not an array", ->
		nsType = {n: Number, s: String}
		expect(isValid(val, Array(nsType))).toBe(false) for val in VALUES when not Array.isArray(val)

	test "return true when all elements of the array are of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid([{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}], Array(nsType))).toBe(true)
		expect(isValid([{n: 1, s: "a"}], Array(nsType))).toBe(true)
		expect(isValid([], Array(nsType))).toBe(true)

	test "return false when some elements of the array are not of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid([{n: 1, s: "a"}, val, {n: 3, s: "c"}], Array(nsType))).toBe(false) for val in VALUES
		expect(isValid([val], Array(nsType))).toBe(false) for val in VALUES
		expect(isValid([{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}], Array(nsType))).toBe(false)

describe "Union type elements", ->

	test "return false when value is not an array", ->
		expect(isValid(val, Array([Number, String]))).toBe(false) for val in VALUES when not Array.isArray(val)

	test "return true for an array whom values are strings or numbers", ->
		expect(isValid([], Array([String, Number]))).toBe(true)
		expect(isValid(["foo", "bar", "baz"], Array([String, Number]))).toBe(true)
		expect(isValid(["foo"], Array([String, Number]))).toBe(true)
		expect(isValid([1, 2, 3], Array([String, Number]))).toBe(true)
		expect(isValid([1], Array([String, Number]))).toBe(true)
		expect(isValid(["foo", 1, "bar"], Array([String, Number]))).toBe(true)
		expect(isValid([1, "foo", 2], Array([String, Number]))).toBe(true)

	test "return false when an element of the array is not a string nor a number", ->
		expect(isValid(["foo", val, 1], Array([String, Number]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
		expect(isValid([val], Array([String, Number]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
