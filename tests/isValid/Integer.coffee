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

