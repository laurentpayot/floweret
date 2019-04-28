import {isValid, Any} from '../../dist'
import {VALUES} from '../fixtures'
import TypedSet from '../../dist/types/TypedSet'
import Type from '../../dist/types/Type'

describe "Literal type elements", ->

	test "throw an error when type is literal", ->
		expect(-> TypedSet(1)).toThrow("You cannot have literal Number 1 as 'TypedSet' argument.")
		expect(-> TypedSet(undefined)).toThrow("You cannot have undefined as 'TypedSet' argument.")
		expect(-> TypedSet(null)).toThrow("You cannot have null as 'TypedSet' argument.")

describe "Any type elements", ->

	test "TypedSet() should throw an error", ->
		expect(-> TypedSet()).toThrow("'TypedSet' must have exactly 1 argument.")

	test "TypedSet used as a function should throw an error.", ->
		expect(-> isValid(TypedSet, 1)).toThrow("'TypedSet' must have exactly 1 argument.")

	test "TypedSet(Any) should return a TypedSet instance and log a warning.", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		t = TypedSet(Any)
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(t.constructor.name).toBe("TypedSet")
		expect(t.type).toEqual(Any)
		expect(warn).toHaveBeenCalledWith("Use 'Set' type instead of a TypedSet with elements of any type.")

	test "TypedSet(Any()) should return a TypedSet instance and log a warning.", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		t = TypedSet(Any())
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(t.constructor.name).toBe("TypedSet")
		expect(t.type).toEqual(Any())
		expect(warn).toHaveBeenCalledWith("Use 'Set' type instead of a TypedSet with elements of any type.")

describe "Native type elements", ->

	test "return false when value is not a set", ->
		expect(isValid(TypedSet(Number), val)).toBe(false) for val in VALUES when not val?.constructor is Set
		expect(isValid(TypedSet(String), val)).toBe(false) for val in VALUES when not val?.constructor is Set

	test "return true for a set of numbers", ->
		expect(isValid(TypedSet(Number), new Set([1, 2, 3]))).toBe(true)
		expect(isValid(TypedSet(Number), new Set([1]))).toBe(true)
		expect(isValid(TypedSet(Number), new Set([]))).toBe(true)

	test "return true for a set of strings", ->
		expect(isValid(TypedSet(String), new Set(["foo", "bar", "baz"]))).toBe(true)
		expect(isValid(TypedSet(String), new Set(["foo"]))).toBe(true)
		expect(isValid(TypedSet(String), new Set([]))).toBe(true)

	test "return false when an element of the set is not a number", ->
		expect(isValid(TypedSet(Number), new Set([1, val, 3]))).toBe(false) for val in VALUES when typeof val isnt 'number'
		expect(isValid(TypedSet(Number), new Set([val]))).toBe(false) for val in VALUES when typeof val isnt 'number'

	test "return false when an element of the set is not a string", ->
		expect(isValid(TypedSet(String), new Set(["foo", val, "bar"]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string'
		expect(isValid(TypedSet(String), new Set([val]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string'

describe "Object type elements", ->

	test "return false when value is not a set", ->
		nsType = {n: Number, s: String}
		expect(isValid(TypedSet(nsType), val)).toBe(false) for val in VALUES when not val?.constructor is Set

	test "return true when all elements of the set are of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid(TypedSet(nsType), new Set([{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}]))).toBe(true)
		expect(isValid(TypedSet(nsType), new Set([{n: 1, s: "a"}]))).toBe(true)
		expect(isValid(TypedSet(nsType), new Set([]))).toBe(true)

	test "return false when some elements of the set are not of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid(TypedSet(nsType), new Set([{n: 1, s: "a"}, val, {n: 3, s: "c"}])))
		.toBe(false) for val in VALUES
		expect(isValid(TypedSet(nsType), new Set([val]))).toBe(false) for val in VALUES
		expect(isValid(TypedSet(nsType), new Set([{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}])))
		.toBe(false)

describe "Union type elements", ->

	test "return false when value is not a set", ->
		expect(isValid(TypedSet([Number, String]), val)).toBe(false) for val in VALUES when not val?.constructor is Set

	test "return true for a set whom values are strings or numbers", ->
		expect(isValid(TypedSet([String, Number]), new Set([]))).toBe(true)
		expect(isValid(TypedSet([String, Number]), new Set(["foo", "bar", "baz"]))).toBe(true)
		expect(isValid(TypedSet([String, Number]), new Set(["foo"]))).toBe(true)
		expect(isValid(TypedSet([String, Number]), new Set([1, 2, 3]))).toBe(true)
		expect(isValid(TypedSet([String, Number]), new Set([1]))).toBe(true)
		expect(isValid(TypedSet([String, Number]), new Set(["foo", 1, "bar"]))).toBe(true)
		expect(isValid(TypedSet([String, Number]), new Set([1, "foo", 2]))).toBe(true)

	test "return false when an element of the set is not a string nor a number", ->
		expect(isValid(TypedSet([String, Number]), new Set(["foo", val, 1]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
		expect(isValid(TypedSet([String, Number]), new Set([val]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
