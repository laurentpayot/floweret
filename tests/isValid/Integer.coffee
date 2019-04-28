import {isValid} from '../../dist'
import Integer from '../../dist/types/Integer'

test "throw an error when Integer arguments are not numers", ->
	expect(-> isValid(Integer('100'), 1)).toThrow("'Integer' arguments must be numbers.")
	expect(-> isValid(Integer(1, '100'), 1)).toThrow("'Integer' arguments must be numbers.")
	expect(-> isValid(Integer('1', 100), 1)).toThrow("'Integer' arguments must be numbers.")
	expect(-> isValid(Integer('1', '100'), 1)).toThrow("'Integer' arguments must be numbers.")

test "not throw an error when Integer is used as a function", ->
	expect(isValid(Integer, 1)).toBe(true)

test "not throw an error when Integer is used without arguments", ->
	expect(isValid(Integer(), 1)).toBe(true)

test "return true for an integer number", ->
	expect(isValid(Integer, 1)).toBe(true)
	expect(isValid(Integer, 0)).toBe(true)
	expect(isValid(Integer, -0)).toBe(true)
	expect(isValid(Integer, -1)).toBe(true)

test "return false for an decimal number", ->
	expect(isValid(Integer, 1.1)).toBe(false)
	expect(isValid(Integer, 0.1)).toBe(false)
	expect(isValid(Integer, -0.1)).toBe(false)
	expect(isValid(Integer, -1.1)).toBe(false)

test "max value", ->
	expect(isValid(Integer(10), 9)).toBe(true)
	expect(isValid(Integer(10), 10)).toBe(true)
	expect(isValid(Integer(10), 11)).toBe(false)
	expect(-> isValid( Integer(-10), -11))
	.toThrow("'Integer' max value used alone cannot be negative.")

test "range values", ->
	expect(isValid(Integer(2, 10), 9)).toBe(true)
	expect(isValid(Integer(-2, 10), 9)).toBe(true)
	expect(isValid(Integer(-2, 10), -9)).toBe(false)
	expect(isValid(Integer(2, 10), 10)).toBe(true)
	expect(isValid(Integer(2, 10), 2)).toBe(true)
	expect(isValid(Integer(2, 10), 11)).toBe(false)
	expect(isValid(Integer(-2, 10), -3)).toBe(false)
	expect(isValid(Integer(-20, -10), -11)).toBe(true)
	expect(isValid(Integer(-20, -10), -21)).toBe(false)
	expect(isValid(Integer(-20, -10), -9)).toBe(false)
