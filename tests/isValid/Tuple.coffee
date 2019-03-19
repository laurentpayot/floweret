import {isValid} from '../../src'
import Tuple from '../../src/types/Tuple'
import Type from '../../src/types/Type'
import Any from '../../src/types/Any'

test "throw an error when Tuple is used as a function", ->
	expect(-> isValid(1, Tuple)).toThrow("'Tuple' must have at least 2 arguments.")

test "throw an error when Tuple is used without arguments", ->
	expect(-> isValid(1, Tuple())).toThrow("'Tuple' must have at least 2 arguments.")

describe "Any type elements", ->

	test "Tuple of Any should return array of empty elements", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = Tuple(Any, Any)
		jest.restoreAllMocks()
		expect(t.constructor.name).toBe("Tuple")
		expect(t.types).toEqual([Any, Any])
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Array(2)' type instead of a Tuple of 2 values of any type'.")

	test "Tuple of Any() should return array of empty elements", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = Tuple(Any(), Any())
		jest.restoreAllMocks()
		expect(t.constructor.name).toBe("Tuple")
		expect(t.types).toEqual([Any(), Any()])
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Array(2)' type instead of a Tuple of 2 values of any type'.")

describe "Native type elements", ->

	test "return true when value is an array correspondig to Tuple type", ->
		expect(isValid([1, true, "three"], Tuple(Number, Boolean, String))).toBe(true)

	test "return false when value is an array not correspondig to Tuple type", ->
		expect(isValid(["1", true, "three"], Tuple(Number, Boolean, String))).toBe(false)

	test "return false when value is a number", ->
		expect(isValid(1, Tuple(Number, Boolean, String))).toBe(false)

	test "return false when value is an empty array", ->
		expect(isValid([], Tuple(Number, Boolean, String))).toBe(false)
