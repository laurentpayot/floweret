import {isValid} from '../../dist'
import Integer from '../../dist/types/Integer'

test "throw an error when Integer arguments are not numers", ->
	expect(-> isValid(1, Integer('100'))).toThrow("'Integer' arguments must be numbers.")
	expect(-> isValid(1, Integer(1, '100'))).toThrow("'Integer' arguments must be numbers.")
	expect(-> isValid(1, Integer('1', 100))).toThrow("'Integer' arguments must be numbers.")
	expect(-> isValid(1, Integer('1', '100'))).toThrow("'Integer' arguments must be numbers.")

test "not throw an error when Integer is used as a function", ->
	expect(isValid(1, Integer)).toBe(true)

test "not throw an error when Integer is used without arguments", ->
	expect(isValid(1, Integer())).toBe(true)

test "return true for an integer number", ->
	expect(isValid(1, Integer)).toBe(true)
	expect(isValid(0, Integer)).toBe(true)
	expect(isValid(-0, Integer)).toBe(true)
	expect(isValid(-1, Integer)).toBe(true)

test "return false for an decimal number", ->
	expect(isValid(1.1, Integer)).toBe(false)
	expect(isValid(0.1, Integer)).toBe(false)
	expect(isValid(-0.1, Integer)).toBe(false)
	expect(isValid(-1.1, Integer)).toBe(false)

test "max value", ->
	expect(isValid(9, Integer(10))).toBe(true)
	expect(isValid(10, Integer(10))).toBe(true)
	expect(isValid(11, Integer(10))).toBe(false)
	expect(-> isValid(-11,  Integer(-10)))
	.toThrow("'Integer' max value used alone cannot be negative.")

test "range values", ->
	expect(isValid(9, Integer(2, 10))).toBe(true)
	expect(isValid(9, Integer(-2, 10))).toBe(true)
	expect(isValid(-9, Integer(-2, 10))).toBe(false)
	expect(isValid(10, Integer(2, 10))).toBe(true)
	expect(isValid(2, Integer(2, 10))).toBe(true)
	expect(isValid(11, Integer(2, 10))).toBe(false)
	expect(isValid(-3, Integer(-2, 10))).toBe(false)
	expect(isValid(-11, Integer(-20, -10))).toBe(true)
	expect(isValid(-21, Integer(-20, -10))).toBe(false)
	expect(isValid(-9, Integer(-20, -10))).toBe(false)
