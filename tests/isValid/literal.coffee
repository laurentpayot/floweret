import {isValid} from '../../dist'


test "return true when value is the same string as the type literal, false if different", ->
	expect(isValid("foo", "foo")).toBe(true)
	expect(isValid("Énorme !", "Énorme !")).toBe(true)
	expect(isValid('', '')).toBe(true)
	expect(isValid(' ', ' ')).toBe(true)
	expect(isValid("foo", "Foo")).toBe(false)
	expect(isValid("foo", "string")).toBe(false)
	expect(isValid("foo", "String")).toBe(false)
	expect(isValid("String", String)).toBe(false)

test "return true when value is the same number as the type literal, false if different", ->
	expect(isValid(1234, 1234)).toBe(true)
	expect(isValid(1234.56, 1234.56)).toBe(true)
	expect(isValid(-1, -1)).toBe(true)
	expect(isValid(1234, 1235)).toBe(false)
	expect(isValid(1234, -1234)).toBe(false)
	expect(isValid(1234, Number)).toBe(false)

test "return true when value is the same boolean as the type literal, false if different", ->
	expect(isValid(true, true)).toBe(true)
	expect(isValid(true, false)).toBe(false)
	expect(isValid(false, false)).toBe(true)
	expect(isValid(false, true)).toBe(false)
	expect(isValid(true, Boolean)).toBe(false)
	expect(isValid(false, Boolean)).toBe(false)
