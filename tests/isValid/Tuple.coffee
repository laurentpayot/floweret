import {isValid} from '../../src'
import Tuple from '../../src/types/Tuple'

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
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Array(2)' type instead of a Tuple of 2 values of any type'.")
		expect(t.constructor.name).to.equal("Tuple")
		expect(t.types).to.eql([Any, Any])

	test "Tuple of Any() should return array of empty elements", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = Tuple(Any(), Any())
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Use 'Array(2)' type instead of a Tuple of 2 values of any type'.")
		expect(t.constructor.name).to.equal("Tuple")
		expect(t.types).to.eql([Any(), Any()])

describe "Native type elements", ->

	test "return true when value is an array correspondig to Tuple type", ->
		expect(isValid([1, true, "three"], Tuple(Number, Boolean, String))).toBe(true)

	test "return false when value is an array not correspondig to Tuple type", ->
		expect(isValid(["1", true, "three"], Tuple(Number, Boolean, String))).toBe(false)

	test "return false when value is a number", ->
		expect(isValid(1, Tuple(Number, Boolean, String))).toBe(false)

	test "return false when value is an empty array", ->
		expect(isValid([], Tuple(Number, Boolean, String))).toBe(false)
