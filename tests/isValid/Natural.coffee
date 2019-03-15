import {isValid} from '../../src'
import Natural from '../../src/types/Natural'

test "throw an error when Natural arguments are not numers", ->
	expect(-> isValid(1, Natural('100')))
	.toThrow("'Natural' arguments must be numbers.")

test "throw an error when Natural arguments are negative", ->
	expect(-> isValid(1, Natural(-1)))
	.toThrow("'Natural' arguments must be positive numbers.")

test "throw an error when Natural arguments are negative", ->
	expect(-> isValid(1, Natural(-100, -10)))
	.toThrow("'Natural' arguments must be positive numbers.")

test "return false for an negative integer", ->
	expect(isValid(-1, Natural)).toBe(false)

test "return true for an positive integer", ->
	expect(isValid(1, Natural)).toBe(true)

test "return true for zero", ->
	expect(isValid(0, Natural)).toBe(true)
	expect(isValid(-0, Natural)).toBe(true)

