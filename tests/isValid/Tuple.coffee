import {isValid} from '../../dist'
import Tuple from '../../dist/types/Tuple'
import Type from '../../dist/types/Type'
import Any from '../../dist/types/Any'

test "throw an error when Tuple is used as a function", ->
	expect(-> isValid(Tuple, 1)).toThrow("'Tuple' must have at least 2 arguments.")

test "throw an error when Tuple is used without arguments", ->
	expect(-> isValid(Tuple(), 1)).toThrow("'Tuple' must have at least 2 arguments.")

describe "Any type elements", ->

	test "Tuple of Any should return array of empty elements", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		t = Tuple(Any, Any)
		jest.restoreAllMocks()
		expect(t.constructor.name).toBe("Tuple")
		expect(t.types).toEqual([Any, Any])
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Array(2)' type instead of a Tuple of 2 values of any type'.")

	test "Tuple of Any() should return array of empty elements", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		t = Tuple(Any(), Any())
		jest.restoreAllMocks()
		expect(t.constructor.name).toBe("Tuple")
		expect(t.types).toEqual([Any(), Any()])
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Array(2)' type instead of a Tuple of 2 values of any type'.")

describe "Native type elements", ->

	test "return true when value is an array correspondig to Tuple type", ->
		expect(isValid(Tuple(Number, Boolean, String), [1, true, "three"])).toBe(true)

	test "return false when value is an array not correspondig to Tuple type", ->
		expect(isValid(Tuple(Number, Boolean, String), ["1", true, "three"])).toBe(false)

	test "return false when value is a number", ->
		expect(isValid(Tuple(Number, Boolean, String), 1)).toBe(false)

	test "return false when value is an empty array", ->
		expect(isValid(Tuple(Number, Boolean, String), [])).toBe(false)
