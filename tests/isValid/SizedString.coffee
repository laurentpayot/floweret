import {isValid} from '../../dist'
import SizedString from '../../dist/types/SizedString'

test "throw an error when SizedString is used as a function", ->
	expect(-> isValid(SizedString, "123")).toThrow("'SizedString' must have at least 1 argument.")

test "throw an error when SizedString is used without arguments", ->
	expect(-> isValid(SizedString(), "123")).toThrow("'SizedString' must have at least 1 argument.")

test "throw an error when SizedString arguments are not numers", ->
	expect(-> isValid(SizedString('100'), "123"))
	.toThrow("'SizedString' arguments must be positive integers.")

test "throw an error when SizedString arguments are negative", ->
	expect(-> isValid(SizedString(-1), "123"))
	.toThrow("'SizedString' arguments must be positive integers.")

test "throw an error when SizedString arguments are negative", ->
	expect(-> isValid(SizedString(-100, -10), "123"))
	.toThrow("'SizedString' arguments must be positive integers.")

test "throw an error when SizedString first argument > second non-zero argument", ->
	expect(-> isValid(SizedString(3, 1), "123"))
	.toThrow("'SizedString' non-zero maximum length cannot be less than minimum length.")

test "too long string", ->
	expect(isValid(SizedString(3), "1234")).toBe(false)
	expect(isValid(SizedString(1, 3), "1234")).toBe(false)
	expect(isValid(SizedString(3), "12345")).toBe(false)
	expect(isValid(SizedString(1, 3), "12345")).toBe(false)

test "too short string", ->
	expect(isValid(SizedString(4, 10), "")).toBe(false)
	expect(isValid(SizedString(4, 10), "123")).toBe(false)
	expect(isValid(SizedString(4, 0), "")).toBe(false)
	expect(isValid(SizedString(4, 0), "123")).toBe(false)
	expect(isValid(SizedString(4, 10), "12")).toBe(false)
	expect(isValid(SizedString(4, 0), "12")).toBe(false)

test "ok string max length", ->
	expect(isValid(SizedString(5), "")).toBe(true)
	expect(isValid(SizedString(5), "1234")).toBe(true)
	expect(isValid(SizedString(5), "12345")).toBe(true)

test "ok string length range", ->
	expect(isValid(SizedString(0, 5), "")).toBe(true)
	expect(isValid(SizedString(1, 5), "1234")).toBe(true)
	expect(isValid(SizedString(4, 5), "12345")).toBe(true)
	expect(isValid(SizedString(1, 5), "1")).toBe(true)
	expect(isValid(SizedString(1, 5), "12")).toBe(true)

test "ok string min length", ->
	expect(isValid(SizedString(0, 0), "")).toBe(true)
	expect(isValid(SizedString(1, 0), "1")).toBe(true)
	#expect(isValid(SizedString(1, 0), "12")).toBe(true)
	#expect(isValid(SizedString(2, 0), "12")).toBe(true)
	#expect(isValid(SizedString(2, 0), "12345")).toBe(true)
