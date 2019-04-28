import {isValid} from '../../dist'
import {VALUES} from '../fixtures'

describe "Native type elements", ->

	test "return false when value is not an array", ->
		expect(isValid(Array(Number), val)).toBe(false) for val in VALUES when not Array.isArray(val)
		expect(isValid(Array(String), val)).toBe(false) for val in VALUES when not Array.isArray(val)

	test "return true for an array of numbers", ->
		expect(isValid(Array(Number), [1, 2, 3])).toBe(true)
		expect(isValid(Array(Number), [1])).toBe(true)
		expect(isValid(Array(Number), [])).toBe(true)

	test "return true for an array of strings", ->
		expect(isValid(Array(String), ["foo", "bar", "baz"])).toBe(true)
		expect(isValid(Array(String), ["foo"])).toBe(true)
		expect(isValid(Array(String), [])).toBe(true)

	test "return false when an element of the array is not a number", ->
		expect(isValid(Array(Number), [1, val, 3])).toBe(false) for val in VALUES when typeof val isnt 'number'
		expect(isValid(Array(Number), [val])).toBe(false) for val in VALUES when typeof val isnt 'number'

	# TODO: test typed array optimizations

	test "return false when an element of the array is not a string", ->
		expect(isValid(Array(String), ["foo", val, "bar"])).toBe(false) \
			for val in VALUES when typeof val isnt 'string'
		expect(isValid(Array(String), [val])).toBe(false) \
			for val in VALUES when typeof val isnt 'string'

describe "Object type elements", ->

	test "return false when value is not an array", ->
		nsType = {n: Number, s: String}
		expect(isValid(Array(nsType), val)).toBe(false) for val in VALUES when not Array.isArray(val)

	test "return true when all elements of the array are of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid(Array(nsType), [{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}])).toBe(true)
		expect(isValid(Array(nsType), [{n: 1, s: "a"}])).toBe(true)
		expect(isValid(Array(nsType), [])).toBe(true)

	test "return false when some elements of the array are not of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid(Array(nsType), [{n: 1, s: "a"}, val, {n: 3, s: "c"}])).toBe(false) for val in VALUES
		expect(isValid(Array(nsType), [val])).toBe(false) for val in VALUES
		expect(isValid(Array(nsType), [{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}])).toBe(false)

describe "Union type elements", ->

	test "return false when value is not an array", ->
		expect(isValid(Array([Number, String]), val)).toBe(false) for val in VALUES when not Array.isArray(val)

	test "return true for an array whom values are strings or numbers", ->
		expect(isValid(Array([String, Number]), [])).toBe(true)
		expect(isValid(Array([String, Number]), ["foo", "bar", "baz"])).toBe(true)
		expect(isValid(Array([String, Number]), ["foo"])).toBe(true)
		expect(isValid(Array([String, Number]), [1, 2, 3])).toBe(true)
		expect(isValid(Array([String, Number]), [1])).toBe(true)
		expect(isValid(Array([String, Number]), ["foo", 1, "bar"])).toBe(true)
		expect(isValid(Array([String, Number]), [1, "foo", 2])).toBe(true)

	test "return false when an element of the array is not a string nor a number", ->
		expect(isValid(Array([String, Number]), ["foo", val, 1])).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
		expect(isValid(Array([String, Number]), [val])).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
