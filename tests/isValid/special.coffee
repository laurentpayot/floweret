import {NATIVE_TYPES, VALUES, testTypes} from '../fixtures'
import {isValid, Any, maybe, etc} from '../../dist'
import Type from '../../dist/types/Type'
import promised from '../../dist/types/promised'
import constraint from '../../dist/types/constraint'


describe "Empty array", ->

	test "return true for empty array only", ->
		expect(isValid([], [])).toBe(true)
		expect(isValid([], v)).toBe(false) for v in VALUES when not (Array.isArray(v) and not v.length)

describe "Empty object", ->

	test "return true for empty object only", ->
		expect(isValid({}, {})).toBe(true)
		expect(isValid({}, v)).toBe(false) for v in VALUES \
			when not (v?.constructor is Object and not Object.keys(v).length)

describe "Any type", ->

	test "Any type should return true for all values", ->
		expect(isValid(Any, val)).toBe(true) for val in VALUES

	test "Any() type should return true for all values", ->
		expect(isValid(Any(), val)).toBe(true) for val in VALUES

	test "Any(Number) type should throw an error", ->
		expect(-> isValid(Any(Number), 1)).toThrow("'Any' cannot have any arguments.")

	test "Any([]) type should throw an error", ->
		expect(-> isValid(Any([]), 1)).toThrow("'Any' cannot have any arguments.")

describe "Maybe type", ->

	test "maybe(Any) should not return Any type.", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		expect(maybe(Any)).toEqual([undefined, Any])
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Any is not needed as 'maybe' argument.")

	test "maybe(Any()) should not return Any type.", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		expect(maybe(Any())).toEqual([undefined, Any()])
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Any is not needed as 'maybe' argument.")

	test "maybe should throw an error when used as with more than 1 argument", ->
		expect(-> isValid(maybe(Number, String), 1))
		.toThrow("'maybe' must have exactly 1 argument.")

	test "maybe(undefined) should throw an error", ->
		expect(-> isValid(maybe(undefined), 1))
		.toThrow("'maybe' argument cannot be undefined.")

	test "return true when value is undefined.", ->
		expect(isValid(maybe(t), undefined)).toBe(true) for t in NATIVE_TYPES when t isnt undefined

	test "return true for a null type, false for other types.", ->
		expect(isValid(maybe(null), null)).toBe(true)
		expect(isValid(maybe(t), null)).toBe(false) for t in NATIVE_TYPES when t isnt undefined and t isnt null

	test "return true for a number type, false for other types.", ->
		expect(isValid(maybe(Number), 1.1)).toBe(true)
		expect(isValid(maybe(t), 1.1)).toBe(false) for t in NATIVE_TYPES when t isnt undefined and t isnt Number

	test "return true for a string type, false for other types.", ->
		expect(isValid(maybe(String), "Énorme !")).toBe(true)
		expect(isValid(maybe(t), "Énorme !")).toBe(false) for t in NATIVE_TYPES when t isnt undefined and t isnt String

	test "return true for a Number or a String or undefined, when union is used", ->
		expect(isValid(maybe([Number, String]), 1)).toBe(true)
		expect(isValid(maybe([Number, String]), '1')).toBe(true)
		expect(isValid(maybe([Number, String]), undefined)).toBe(true)

	test "maybe() should throw an error when type is ommited", ->
		expect(-> isValid(maybe(), 1))
		.toThrow("'maybe' must have exactly 1 argument.")

	test "maybe should throw an error when used as a function", ->
		expect(-> isValid(maybe, 1)).toThrow("'maybe' must have exactly 1 argument")

describe "Type type", ->

	test "throw an error when creating an instance of Type", ->
		expect(-> new Type()).toThrow("Abstract class 'Type' cannot be instantiated directly.")

describe "Promised type", ->

	test "throw an error for a promised number.", ->
		expect(-> isValid(Promise.resolve(Number), Promise.resolve(1)))
		.toThrow("Type can not be an instance of Promise. Use Promise as type instead.")
		expect(-> isValid(promised(Number), Promise.resolve(1)))
		.toThrow("Type can not be an instance of Promise. Use Promise as type instead.")

describe "Custom type (class)", ->

	test "return true when type is MyClass, false for other types", ->
		class MyClass
		mc = new MyClass
		testTypes(mc, MyClass)

describe "Unmanaged Types", ->

	test "throw an error when etc is used as a function", ->
		expect(-> isValid(etc, 1))
		.toThrow("'etc' cannot be used in types.")

	test "throw an error when etc is used without parameter", ->
		expect(-> isValid(etc(), 1))
		.toThrow("'etc' cannot be used in types.")

	test "throw an error when type is not a native type nor an object nor an array of types
		nor a string or number or boolean literal.", ->
		expect(-> isValid(Symbol("foo"), val))
		.toThrow("Type can not be an instance of Symbol. Use Symbol as type instead.") for val in VALUES

describe "Constraint", ->

	test "return true when validator function is truthy for the value", ->
		Int = constraint(Number.isInteger)
		expect(isValid(Int, 100)).toBe(true)
		expect(isValid(Int, -10)).toBe(true)
		expect(isValid(Int, 0)).toBe(true)
		expect(isValid(Int, val)).toBe(false) for val in VALUES when not Number.isInteger(val)
