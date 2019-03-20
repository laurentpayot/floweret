import {isValid, Any} from '../../dist'
import {VALUES} from '../fixtures'
import TypedMap from '../../dist/types/TypedMap'
import Type from '../../dist/types/Type'

describe "Literal type elements", ->

	test "throw an error when literals for both keys and values types", ->
		expect(-> TypedMap("foo", 1))
		.toThrow("You cannot have both literal String \"foo\" as keys type
					and literal Number 1 as values type in a TypedMap.")
		expect(-> TypedMap(null, undefined))
		.toThrow("You cannot have both null as keys type and undefined as values type in a TypedMap.")
		expect(-> TypedMap(undefined, undefined))
		.toThrow("You cannot have both undefined as keys type and undefined as values type in a TypedMap.")

describe "Any type elements", ->

	test "TypedMap() should throw an error.", ->
		expect(-> TypedMap()).toThrow("'TypedMap' must have at least 1 argument.")

	test "TypedMap used as a function should throw an error.", ->
		expect(-> isValid(1, TypedMap)).toThrow("'TypedMap' must have at least 1 argument.")

	test "TypedMap(Any) should return a TypedMap instance and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = TypedMap(Any)
		jest.restoreAllMocks()
		expect(t.constructor.name).toBe("TypedMap")
		expect(t.valuesType).toEqual(Any)
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Map' type instead of a TypedMap with values of any type.")

	test "TypedMap(Any, Any) should return a TypedMap instance and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = TypedMap(Any, Any)
		jest.restoreAllMocks()
		expect(t.constructor.name).toBe("TypedMap")
		expect([t.valuesType, t.keysType]).toEqual([Any, Any])
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Map' type instead of a TypedMap with keys and values of any type.")

	test "TypedMap(Any()) should return a TypedMap instance and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = TypedMap(Any())
		jest.restoreAllMocks()
		expect(t.constructor.name).toBe("TypedMap")
		expect(t.valuesType).toEqual(Any())
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Map' type instead of a TypedMap with values of any type.")

	test "TypedMap(Any(), Any()) should return a TypedMap instance and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = TypedMap(Any(), Any())
		jest.restoreAllMocks()
		expect(t.constructor.name).toBe("TypedMap")
		expect([t.valuesType, t.keysType]).toEqual([Any(), Any()])
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Map' type instead of a TypedMap with keys and values of any type.")

describe "Native type elements", ->

	test "return false when value is not a Map", ->
		expect(isValid(val, TypedMap(Number))).toBe(false) for val in VALUES when not val?.constructor is Map
		expect(isValid(val, TypedMap(String))).toBe(false) for val in VALUES when not val?.constructor is Map
		expect(isValid(val, TypedMap(Number, String))).toBe(false) for val in VALUES when not val?.constructor is Map
		expect(isValid(val, TypedMap(String, Number))).toBe(false) for val in VALUES when not val?.constructor is Map

	test "return true for a Map of numbers", ->
		expect(isValid(new Map([['one', 1], ['two', 2], ['three', 3]]), TypedMap(Number))).toBe(true)
		expect(isValid(new Map([['one', 1]]), TypedMap(Number))).toBe(true)
		expect(isValid(new Map([]), TypedMap(Number))).toBe(true)

	test "return true for a Map of strings -> numbers", ->
		expect(isValid(new Map([['one', 1], ['two', 2], ['three', 3]]), TypedMap(String, Number))).toBe(true)
		expect(isValid(new Map([['one', 1]]), TypedMap(String, Number))).toBe(true)
		expect(isValid(new Map([]), TypedMap(String, Number))).toBe(true)

	test "return true for a Map of strings", ->
		expect(isValid(new Map([[1, 'one'], [2, 'two'], [3, 'three']]), TypedMap(String))).toBe(true)
		expect(isValid(new Map([[1, 'one']]), TypedMap(String))).toBe(true)
		expect(isValid(new Map([]), TypedMap(String))).toBe(true)

	test "return true for a Map of numbers -> strings", ->
		expect(isValid(new Map([[1, 'one'], [2, 'two'], [3, 'three']]), TypedMap(Number, String))).toBe(true)
		expect(isValid(new Map([[1, 'one']]), TypedMap(Number, String))).toBe(true)
		expect(isValid(new Map([]), TypedMap(Number, String))).toBe(true)

	test "return false when an element of the Map is not a number", ->
		expect(isValid(new Map([['one', 1], ['two', val], ['three', 3]]), TypedMap(Number)))
		.toBe(false) for val in VALUES when typeof val isnt 'number'
		expect(isValid(new Map([['foo', val]]), TypedMap(Number)))
		.toBe(false) for val in VALUES when typeof val isnt 'number'

	test "return false when an element of the Map is not a string", ->
		expect(isValid(new Map([[1, 'one'], [2, val], [3, 'three']]), TypedMap(String)))
		.toBe(false) for val in VALUES when typeof val isnt 'string'
		expect(isValid(new Map([[1234, val]]), TypedMap(String)))
		.toBe(false) for val in VALUES when typeof val isnt 'string'

	test "return false when a value of the Map number -> string is not a string", ->
		expect(isValid(new Map([[1, 'one'], [2, val], [3, 'three']]), TypedMap(Number, String)))
		.toBe(false) for val in VALUES when typeof val isnt 'string'
		expect(isValid(new Map([[1234, val]]), TypedMap(Number, String)))
		.toBe(false) for val in VALUES when typeof val isnt 'string'

	test "return false when a key of the Map number -> string is not a string", ->
		expect(isValid(new Map([[1, 'one'], [val, 'two'], [3, 'three']]), TypedMap(Number, String)))
		.toBe(false) for val in VALUES when typeof val isnt 'number'
		expect(isValid(new Map([[val, 'foo']]), TypedMap(Number, String)))
		.toBe(false) for val in VALUES when typeof val isnt 'number'

describe "Object type elements", ->

	test "return false when value is not a Map", ->
		nsType = {n: Number, s: String}
		expect(isValid(val, TypedMap(nsType))).toBe(false) for val in VALUES when not val?.constructor is Map

	test "return true when all elements of the Map are of a given object type", ->
		nsType = {n: Number, s: String}
		m = new Map([[1, {n: 1, s: "a"}], [2, {n: 2, s: "b"}], [3, {n: 3, s: "c"}]])
		expect(isValid(m, TypedMap(nsType))).toBe(true)
		expect(isValid(new Map([[1, {n: 1, s: "a"}]]), TypedMap(nsType))).toBe(true)
		expect(isValid(new Map([]), TypedMap(nsType))).toBe(true)

	test "return false when some elements of the Map are not of a given object type", ->
		nsType = {n: Number, s: String}
		expect(isValid(new Map([[1, {n: 1, s: "a"}], [2, val], [3, {n: 3, s: "c"}]]),
						TypedMap(nsType))).toBe(false) for val in VALUES
		expect(isValid(new Map([[1, val]]), TypedMap(nsType))).toBe(false) for val in VALUES
		expect(isValid(new Map([[1, {n: 1, s: "a"}], [2, {foo: 2, s: "b"}], [3, {n: 3, s: "c"}]]),
						TypedMap(nsType))).toBe(false)

describe "Union type elements", ->

	test "return false when value is not a Map", ->
		expect(isValid(val, TypedMap([Number, String]))).toBe(false) for val in VALUES when not val?.constructor is Map

	test "return true for a Map whom values are strings or numbers", ->
		expect(isValid(new Map([]), TypedMap([String, Number]))).toBe(true)
		expect(isValid(new Map([[1, "foo"], [2, "bar"], [3, "baz"]]), TypedMap([String, Number]))).toBe(true)
		expect(isValid(new Map([[1, "foo"]]), TypedMap([String, Number]))).toBe(true)
		expect(isValid(new Map([[1, 1], [2, 2], [3, 3]]), TypedMap([String, Number]))).toBe(true)
		expect(isValid(new Map([[1, 1]]), TypedMap([String, Number]))).toBe(true)
		expect(isValid(new Map([[1, "foo"], [2, 1], [3, "bar"]]), TypedMap([String, Number]))).toBe(true)
		expect(isValid(new Map([[1, "foo"], [2, 2]]), TypedMap([String, Number]))).toBe(true)

	test "return false when an element of the Map is not a string nor a number", ->
		expect(isValid(new Map([[1, "foo"], [2, val], [3, 1]]), TypedMap([String, Number]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
		expect(isValid(new Map([[1, val]]), TypedMap([String, Number]))).toBe(false) \
			for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
