import {isValid, Any} from '../../src'
import {VALUES} from '../fixtures'
import TypedSet from '../../src/types/TypedSet'
import Type from '../../src/types/Type'

describe "Literal type elements", ->

	test "throw an error when type is literal", ->
		expect(-> TypedSet(1)).toThrow("You cannot have literal Number 1 as 'TypedSet' argument.")
		expect(-> TypedSet(undefined)).toThrow("You cannot have undefined as 'TypedSet' argument.")
		expect(-> TypedSet(null)).toThrow("You cannot have null as 'TypedSet' argument.")

describe "Any type elements", ->

	test "TypedSet() should throw an error", ->
		expect(-> TypedSet()).toThrow("'TypedSet' must have exactly 1 argument.")

	test "TypedSet used as a function should throw an error.", ->
		expect(-> isValid(1, TypedSet)).toThrow("'TypedSet' must have exactly 1 argument.")

	test "TypedSet(Any) should return a TypedSet instance and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = TypedSet(Any)
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(t.constructor.name).toBe("TypedSet")
		expect(t.type).toEqual(Any)
		expect(warn).toHaveBeenCalledWith("Use 'Set' type instead of a TypedSet with elements of any type.")

	test "TypedSet(Any()) should return a TypedSet instance and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = TypedSet(Any())
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(t.constructor.name).toBe("TypedSet")
		expect(t.type).toEqual(Any())
		expect(warn).toHaveBeenCalledWith("Use 'Set' type instead of a TypedSet with elements of any type.")

describe "Native type elements", ->

	test "return false when value is not a set", ->
		expect(isValid(val, TypedSet(Number))).toBe(false) for val in VALUES when not val?.constructor is Set
		expect(isValid(val, TypedSet(String))).toBe(false) for val in VALUES when not val?.constructor is Set

	test "return true for a set of numbers", ->
		expect(isValid(new Set([1, 2, 3]), TypedSet(Number))).toBe(true)
		expect(isValid(new Set([1]), TypedSet(Number))).toBe(true)
		expect(isValid(new Set([]), TypedSet(Number))).toBe(true)

	test "return true for a set of strings", ->
		expect(isValid(new Set(["foo", "bar", "baz"]), TypedSet(String))).toBe(true)
		expect(isValid(new Set(["foo"]), TypedSet(String))).toBe(true)
		expect(isValid(new Set([]), TypedSet(String))).toBe(true)

	test "return false when an element of the set is not a number", ->
		expect(isValid(new Set([1, val, 3]), TypedSet(Number))).toBe(false) for val in VALUES when typeof val isnt 'number'
		expect(isValid(new Set([val]), TypedSet(Number))).toBe(false) for val in VALUES when typeof val isnt 'number'

	test "return false when an element of the set is not a string", ->
		expect(isValid(new Set(["foo", val, "bar"]), TypedSet(String))).toBe(false) \
			for val in VALUES when typeof val isnt 'string'
		expect(isValid(new Set([val]), TypedSet(String))).toBe(false) \
			for val in VALUES when typeof val isnt 'string'

describe "Object type elements", ->

	test "return false when value is not a set", ->
		nsType = {n: Number, s: String}
		expect(isValid(val, TypedSet(nsType))).toBe(false) for val in VALUES when not val?.constructor is Set

	test "return true when all elements of the set are of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid(new Set([{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}]), TypedSet(nsType))).toBe(true)
		expect(isValid(new Set([{n: 1, s: "a"}]), TypedSet(nsType))).toBe(true)
		expect(isValid(new Set([]), TypedSet(nsType))).toBe(true)

	test "return false when some elements of the set are not of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid(new Set([{n: 1, s: "a"}, val, {n: 3, s: "c"}]), TypedSet(nsType))).toBe(false) for val in VALUES
		expect(isValid(new Set([val]), TypedSet(nsType))).toBe(false) for val in VALUES
		expect(isValid(new Set([{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}]), TypedSet(nsType))).toBe(false)

describe "Union type elements", ->

	test "return false when value is not a set", ->
		expect(isValid(val, TypedSet([Number, String]))).toBe(false) for val in VALUES when not val?.constructor is Set

	test "return true for a set whom values are strings or numbers", ->
		expect(isValid(new Set([]), TypedSet([String, Number]))).toBe(true)
		expect(isValid(new Set(["foo", "bar", "baz"]), TypedSet([String, Number]))).toBe(true)
		expect(isValid(new Set(["foo"]), TypedSet([String, Number]))).toBe(true)
		expect(isValid(new Set([1, 2, 3]), TypedSet([String, Number]))).toBe(true)
		expect(isValid(new Set([1]), TypedSet([String, Number]))).toBe(true)
		expect(isValid(new Set(["foo", 1, "bar"]), TypedSet([String, Number]))).toBe(true)
		expect(isValid(new Set([1, "foo", 2]), TypedSet([String, Number]))).toBe(true)

	test "return false when an element of the set is not a string nor a number", ->
		expect(isValid(new Set(["foo", val, 1]), TypedSet([String, Number]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
		expect(isValid(new Set([val]), TypedSet([String, Number]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
