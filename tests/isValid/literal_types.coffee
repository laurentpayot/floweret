import {isValid} from '../../src'


test "return true when value is the same string as the type literal, false if different", ->
	expect(isValid("foo", "foo")).toBe(true)
	expect(isValid("Énorme !", "Énorme !")).toBe(true)
	expect(isValid('', '')).toBe(true)
	expect(isValid(' ', ' ')).toBe(true)
	expect(isValid("Foo", "foo")).toBe(false)
	expect(isValid("string", "foo")).toBe(false)
	expect(isValid("String", "foo")).toBe(false)
	expect(isValid(String, "String")).toBe(false)

test "return true when value is the same number as the type literal, false if different", ->
	expect(isValid(1234, 1234)).toBe(true)
	expect(isValid(1234.56, 1234.56)).toBe(true)
	expect(isValid(-1, -1)).toBe(true)
	expect(isValid(1235, 1234)).toBe(false)
	expect(isValid(-1234, 1234)).toBe(false)
	expect(isValid(Number, 1234)).toBe(false)

test "return true when value is the same boolean as the type literal, false if different", ->
	expect(isValid(true, true)).toBe(true)
	expect(isValid(false, true)).toBe(false)
	expect(isValid(false, false)).toBe(true)
	expect(isValid(true, false)).toBe(false)
	expect(isValid(Boolean, true)).toBe(false)
	expect(isValid(Boolean, false)).toBe(false)
