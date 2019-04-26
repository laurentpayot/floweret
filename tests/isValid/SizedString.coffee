import {isValid} from '../../dist'
import SizedString from '../../dist/types/SizedString'

test "throw an error when SizedString is used as a function", ->
	expect(-> isValid("123", SizedString)).toThrow("'SizedString' must have at least 1 argument.")

test "throw an error when SizedString is used without arguments", ->
	expect(-> isValid("123", SizedString())).toThrow("'SizedString' must have at least 1 argument.")

test "throw an error when SizedString arguments are not numers", ->
	expect(-> isValid("123", SizedString('100')))
	.toThrow("'SizedString' arguments must be positive integers.")

test "throw an error when SizedString arguments are negative", ->
	expect(-> isValid("123", SizedString(-1)))
	.toThrow("'SizedString' arguments must be positive integers.")

test "throw an error when SizedString arguments are negative", ->
	expect(-> isValid("123", SizedString(-100, -10)))
	.toThrow("'SizedString' arguments must be positive integers.")

test "throw an error when SizedString first argument > second non-zero argument", ->
	expect(-> isValid("123", SizedString(3, 1)))
	.toThrow("'SizedString' non-zero maximum length cannot be less than minimum length.")

test "too long string", ->
	expect(isValid("1234", SizedString(3))).toBe(false)
	expect(isValid("1234", SizedString(1, 3))).toBe(false)
	expect(isValid("12345", SizedString(3))).toBe(false)
	expect(isValid("12345", SizedString(1, 3))).toBe(false)

test "too short string", ->
	expect(isValid("", SizedString(4, 10))).toBe(false)
	expect(isValid("123", SizedString(4, 10))).toBe(false)
	expect(isValid("", SizedString(4, 0))).toBe(false)
	expect(isValid("123", SizedString(4, 0))).toBe(false)
	expect(isValid("12", SizedString(4, 10))).toBe(false)
	expect(isValid("12", SizedString(4, 0))).toBe(false)

test "ok string max length", ->
	expect(isValid("", SizedString(5))).toBe(true)
	expect(isValid("1234", SizedString(5))).toBe(true)
	expect(isValid("12345", SizedString(5))).toBe(true)

test "ok string length range", ->
	expect(isValid("", SizedString(0, 5))).toBe(true)
	expect(isValid("1234", SizedString(1, 5))).toBe(true)
	expect(isValid("12345", SizedString(4, 5))).toBe(true)
	expect(isValid("1", SizedString(1, 5))).toBe(true)
	expect(isValid("12", SizedString(1, 5))).toBe(true)

test "ok string min length", ->
	expect(isValid("", SizedString(0, 0))).toBe(true)
	expect(isValid("1", SizedString(1, 0))).toBe(true)
	#expect(isValid("12", SizedString(1, 0))).toBe(true)
	#expect(isValid("12", SizedString(2, 0))).toBe(true)
	#expect(isValid("12345", SizedString(2, 0))).toBe(true)
