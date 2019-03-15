import {isValid} from '../../src'
import SizedString from '../../src/types/SizedString'

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

test "return false for a too long string", ->
	expect(isValid("123", SizedString(2))).toBe(false)

test "return false for a too short string", ->
	expect(isValid("123", SizedString(4, 10))).toBe(false)
