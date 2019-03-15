import {isValid} from '../../src'

test "return false for empty array", ->
	expect(isValid([], Array(1))).toBe(false)
	expect(isValid([], Array(2))).toBe(false)
	expect(isValid([], Array(3))).toBe(false)

test "return true for same size array of undefined", ->
	expect(isValid([undefined], Array(1))).toBe(true)
	expect(isValid([undefined, undefined], Array(2))).toBe(true)
	expect(isValid([undefined, undefined, undefined], Array(3))).toBe(true)

test "return true for same size array of anything", ->
	expect(isValid([1], Array(1))).toBe(true)
	expect(isValid([1, true], Array(2))).toBe(true)
	expect(isValid([undefined, true], Array(2))).toBe(true)
	expect(isValid([1, true, "three"], Array(3))).toBe(true)
	expect(isValid([1, true, "tree"], Array(3))).toBe(true)
	expect(isValid([undefined, true, "tree"], Array(3))).toBe(true)
	expect(isValid([1, undefined, "tree"], Array(3))).toBe(true)

test "return false for different size array of anything", ->
	expect(isValid([1], Array(2))).toBe(false)
	expect(isValid([1, true], Array(3))).toBe(false)
	expect(isValid([1, 1], Array(3))).toBe(false)
	expect(isValid([undefined, true], Array(4))).toBe(false)
	expect(isValid([1, 1, 1], Array(4))).toBe(false)
	expect(isValid([1, true, "three"], Array(4))).toBe(false)
	expect(isValid([1, true, "tree"], Array(4))).toBe(false)
	expect(isValid([undefined, true, "tree"], Array(4))).toBe(false)
	expect(isValid([1, undefined, "tree"], Array(4))).toBe(false)
