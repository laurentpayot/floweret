import {NATIVE_TYPES, VALUES} from '../fixtures'
import {isValid, Any, maybe} from '../../src'
import {Type} from '../../src/types/_index'


describe "Empty array", ->

	test "return true for empty array only", ->
		expect(isValid(v, [])).toBe(false) for v in VALUES when not (Array.isArray(v) and not v.length)
		expect(isValid([], [])).toBe(true)

describe "Empty object", ->

	test "return true for empty object only", ->
		expect(isValid(v, {})).toBe(false) for v in VALUES \
			when not (v?.constructor is Object and not Object.keys(v).length)
		expect(isValid({}, {})).toBe(true)

describe "Any type", ->

	test "Any type should return true for all values", ->
		expect(isValid(val, Any)).toBe(true) for val in VALUES
		return

	test "Any() type should return true for all values", ->
		expect(isValid(val, Any())).toBe(true) for val in VALUES
		return

	test "Any(Number) type should throw an error", ->
		expect(-> isValid(1, Any(Number))).toThrow("'Any' cannot have any arguments.")

	test "Any([]) type should throw an error", ->
		expect(-> isValid(1, Any([]))).toThrow("'Any' cannot have any arguments.")

describe "Maybe type", ->

	test "maybe(Any) should not return Any type.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		expect(maybe(Any)).toEqual([undefined, Any])
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Any is not needed as 'maybe' argument.")

	test "maybe(Any()) should not return Any type.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		expect(maybe(Any())).toEqual([undefined, Any()])
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Any is not needed as 'maybe' argument.")

	test "maybe should throw an error when used as with more than 1 argument", ->
		expect(-> isValid(1, maybe(Number, String)))
		.toThrow("'maybe' must have exactly 1 argument.")

	test "maybe(undefined) should throw an error", ->
		expect(-> isValid(1, maybe(undefined)))
		.toThrow("'maybe' argument cannot be undefined.")

	test "return true when value is undefined.", ->
		expect(isValid(undefined, maybe(t))).toBe(true) for t in NATIVE_TYPES when t isnt undefined
		return

	test "return true for a null type, false for other types.", ->
		expect(isValid(null, maybe(t))).toBe(false) for t in NATIVE_TYPES when t isnt undefined and t isnt null
		expect(isValid(null, maybe(null))).toBe(true)

	test "return true for a number type, false for other types.", ->
		expect(isValid(1.1, maybe(t))).toBe(false) for t in NATIVE_TYPES when t isnt undefined and t isnt Number
		expect(isValid(1.1, maybe(Number))).toBe(true)

	test "return true for a string type, false for other types.", ->
		expect(isValid("Énorme !", maybe(t))).toBe(false) for t in NATIVE_TYPES when t isnt undefined and t isnt String
		expect(isValid("Énorme !", maybe(String))).toBe(true)

	test "return true for a Number or a String or undefined, when union is used", ->
		expect(isValid(1, maybe([Number, String]))).toBe(true)
		expect(isValid('1', maybe([Number, String]))).toBe(true)
		expect(isValid(undefined, maybe([Number, String]))).toBe(true)

	test "maybe() should throw an error when type is ommited", ->
		expect(-> isValid(1, maybe()))
		.toThrow("'maybe' must have exactly 1 argument.")

	test "maybe should throw an error when used as a function", ->
		expect(-> isValid(1, maybe)).toThrow("'maybe' must have exactly 1 argument")

describe "Type type", ->

	test "throw an error when creating an instance of Type", ->
		expect(-> new Type()).toThrow("Abstract class 'Type' cannot be instantiated directly.")
