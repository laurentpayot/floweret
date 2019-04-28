import {isValid} from '../../dist'

test "return false for empty array", ->
	expect(isValid(Array(1), [])).toBe(false)
	expect(isValid(Array(2), [])).toBe(false)
	expect(isValid(Array(3), [])).toBe(false)

test "return true for same size array of undefined", ->
	expect(isValid(Array(1), [undefined])).toBe(true)
	expect(isValid([undefined, undefined], Array(2))).toBe(true)
	expect(isValid([undefined, undefined, undefined], Array(3))).toBe(true)

test "return true for same size array of anything", ->
	expect(isValid(Array(1), [1])).toBe(true)
	expect(isValid(Array(2), [1, true])).toBe(true)
	expect(isValid(Array(2), [undefined, true])).toBe(true)
	expect(isValid(Array(3), [1, true, "three"])).toBe(true)
	expect(isValid(Array(3), [1, true, "tree"])).toBe(true)
	expect(isValid(Array(3), [undefined, true, "tree"])).toBe(true)
	expect(isValid(Array(3), [1, undefined, "tree"])).toBe(true)

test "return false for different size array of anything", ->
	expect(isValid(Array(2), [1])).toBe(false)
	expect(isValid(Array(3), [1, true])).toBe(false)
	expect(isValid(Array(3), [1, 1])).toBe(false)
	expect(isValid(Array(4), [undefined, true])).toBe(false)
	expect(isValid(Array(4), [1, 1, 1])).toBe(false)
	expect(isValid(Array(4), [1, true, "three"])).toBe(false)
	expect(isValid(Array(4), [1, true, "tree"])).toBe(false)
	expect(isValid(Array(4), [undefined, true, "tree"])).toBe(false)
	expect(isValid(Array(4), [1, undefined, "tree"])).toBe(false)
