import {VALUES} from '../fixtures'
import {isValid} from '../../src'

test "return true if the value is one of the given strings, false otherwise", ->
	expect(isValid("foo", ["foo", "bar"])).toBe(true)
	expect(isValid("bar", ["foo", "bar"])).toBe(true)
	expect(isValid("baz", ["foo", "bar"])).toBe(false)
	expect(isValid(Array, ["foo", "bar"])).toBe(false)

test "return true if the value is one of the given strings, false otherwise", ->
	expect(isValid(1, [1, 2])).toBe(true)
	expect(isValid(2, [1, 2])).toBe(true)
	expect(isValid(3, [1, 2])).toBe(false)
	expect(isValid(Array, [1, 2])).toBe(false)

test "return true for a string or a number value, false otherwise", ->
	expect(isValid("foo", [String, Number])).toBe(true)
	expect(isValid(1234, [String, Number])).toBe(true)
	expect(isValid(null, [String, Number])).toBe(false)
	expect(isValid({}, [String, Number])).toBe(false)
	expect(isValid(new Date(), [Object, Number])).toBe(false)

test "return true for a string or null value, false otherwise", ->
	expect(isValid("foo", [String, null])).toBe(true)
	expect(isValid(null, [String, null])).toBe(true)
	expect(isValid(1234, [String, null])).toBe(false)

test "return true for an object or null value, false otherwise", ->
	expect(isValid({id: 1234, name: "Smith"}, [Object, null])).toBe(true)
	expect(isValid(null, [Object, null])).toBe(true)
	expect(isValid("foo", [Object, null])).toBe(false)

test "return true for an object type or null value, false otherwise", ->
	UserType =
		id: Number
		name: String
	expect(isValid({id: 1234, name: "Smith"}, [UserType, null])).toBe(true)
	expect(isValid(null, [UserType, null])).toBe(true)
	expect(isValid("foo", [UserType, null])).toBe(false)
