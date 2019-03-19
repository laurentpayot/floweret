import {isValid, Any} from '../../src'
import {VALUES} from '../fixtures'
import Type from '../../src/types/Type'
import And from '../../src/types/and'
import Or from '../../src/types/or'
import Not from '../../src/types/not'

describe "And", ->

	test "And with a single value should throw an error", ->
		expect(-> And(1)).toThrow("'and' must have at least 2 arguments.")

	test "And with Any values should return an And instance and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = And(Number, Any)
		jest.restoreAllMocks()
		expect(t.constructor.name).toEqual("And")
		expect(t.types).toEqual([Number, Any])
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Any is not needed as 'and' argument number 2.")

	test "And with undefined value should throw an error.", ->
		expect(-> And(Number, undefined)).toThrow("You cannot have undefined as 'and' argument number 2.")
		expect(-> And(undefined, Number)).toThrow("You cannot have undefined as 'and' argument number 1.")

	test "And with null value should throw an error.", ->
		expect(-> And(Number, null)).toThrow("You cannot have null as 'and' argument number 2.")
		expect(-> And(null, Number)).toThrow("You cannot have null as 'and' argument number 1.")

	test "And with literal value should throw an error.", ->
		expect(-> And(Number, 1))
		.toThrow("You cannot have literal Number 1 as 'and' argument number 2.")
		expect(-> And("foo", Number))
		.toThrow("You cannot have literal String \"foo\" as 'and' argument number 1.")

	test "And with literal values should throw an error.", ->
		expect(-> And(undefined, null, 1, "foo", true, NaN))
		.toThrow("You cannot have undefined as 'and' argument number 1.")

	test "isValid with and() should return true only if value in intersection of array types", ->
		t = And(Array(Number), Array(2))
		expect(isValid([1, 2], t)).toBe(true)
		expect(isValid([1], t)).toBe(false)
		expect(isValid([1, "two"], t)).toBe(false)

	test "isValid with and() should return true only if value in intersection of unions of literal types", ->
		t = And(["foo", "bar"], ["bar", "baz"])
		expect(isValid("bar", t)).toBe(true)
		expect(isValid("foo", t)).toBe(false)
		expect(isValid("baz", t)).toBe(false)

describe "Or", ->

	test "Or with a single value should throw an error", ->
		expect(-> Or(1)).toThrow("'or' must have at least 2 arguments.")

	test "Or with Any values should return an array and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = Or(Number, Any)
		jest.restoreAllMocks()
		expect(t).toEqual([Number, Any])
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Any is inadequate as 'or' argument number 2.")

describe "Not", ->

	test "Not with more than a single value should throw an error", ->
		expect(-> Not(1, 2)).toThrow("'not' must have exactly 1 argument.")

	test "Not with Any value should return a Not instance and log a warning.", ->
		warn = jest.spyOn(Type.prototype, 'warn')
		.mockImplementation(->) # silencing warn()
		t = Not(Any)
		jest.restoreAllMocks()
		expect(t.constructor.name).toEqual("Not")
		expect(t.type).toEqual(Any)
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Any is inadequate as 'not' argument.")

	test "isValid with not() should return true only if value is not of the given type", ->
		t = Not([String, Number])
		expect(isValid("foo", t)).toBe(false)
		expect(isValid(1, t)).toBe(false)
		expect(isValid(true, t)).toBe(true)
		expect(isValid(false, t)).toBe(true)
		expect(isValid(NaN, t)).toBe(true)

