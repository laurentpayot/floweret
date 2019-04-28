import {isValid} from '../../dist'

test "return true if the value is one of the given strings, false otherwise", ->
	expect(isValid(["foo", "bar"], "foo")).toBe(true)
	expect(isValid(["foo", "bar"], "bar")).toBe(true)
	expect(isValid(["foo", "bar"], "baz")).toBe(false)
	expect(isValid(["foo", "bar"], Array)).toBe(false)

test "return true if the value is one of the given strings, false otherwise", ->
	expect(isValid([1, 2], 1)).toBe(true)
	expect(isValid([1, 2], 2)).toBe(true)
	expect(isValid([1, 2], 3)).toBe(false)
	expect(isValid([1, 2], Array)).toBe(false)

test "return true for a string or a number value, false otherwise", ->
	expect(isValid([String, Number], "foo")).toBe(true)
	expect(isValid([String, Number], 1234)).toBe(true)
	expect(isValid([String, Number], null)).toBe(false)
	expect(isValid([String, Number], {})).toBe(false)
	expect(isValid([Object, Number], new Date())).toBe(false)

test "return true for a string or null value, false otherwise", ->
	expect(isValid([String, null], "foo")).toBe(true)
	expect(isValid([String, null], null)).toBe(true)
	expect(isValid([String, null], 1234)).toBe(false)

test "return true for an object or null value, false otherwise", ->
	expect(isValid([Object, null], {id: 1234, name: "Smith"})).toBe(true)
	expect(isValid([Object, null], null)).toBe(true)
	expect(isValid([Object, null], "foo")).toBe(false)

test "return true for an object type or null value, false otherwise", ->
	UserType =
		id: Number
		name: String
	expect(isValid([UserType, null], {id: 1234, name: "Smith"})).toBe(true)
	expect(isValid([UserType, null], null)).toBe(true)
	expect(isValid([UserType, null], "foo")).toBe(false)
