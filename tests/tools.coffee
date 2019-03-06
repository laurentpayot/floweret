import {VALUES, NATIVE_TYPES} from './fixtures'
import {isLiteral, isAny, isEmptyObject} from '../src/tools'
import {Any} from '../src'

describe "isLiteral", ->

	test "return true for undefined", ->
		expect(isLiteral(undefined)).toBe(true)

	test "return true for null", ->
		expect(isLiteral(null)).toBe(true)

	test "return true for NaN", ->
		expect(isLiteral(NaN)).toBe(true)

	test "return true for Infinity", ->
		expect(isLiteral(Infinity)).toBe(true)

	test "return true for -Infinity", ->
		expect(isLiteral(-Infinity)).toBe(true)

	test "return true for 0", ->
		expect(isLiteral(0)).toBe(true)

	test "return true for a number", ->
		expect(isLiteral(100)).toBe(true)
		expect(isLiteral(-100)).toBe(true)
		expect(isLiteral(100.1234)).toBe(true)

	test "return true for empty string", ->
		expect(isLiteral('')).toBe(true)

	test "return true for strings", ->
		expect(isLiteral(val)).toBe(true) for val in VALUES when typeof val is 'string'
		return # Jest: `it` and `test` must return either a Promise or undefined.

	test "return true for booleans", ->
		expect(isLiteral(true)).toBe(true)
		expect(isLiteral(false)).toBe(true)

describe "isAny", ->

	test "return false for native types", ->
		expect(isAny(t)).toBe(false) for t in NATIVE_TYPES
		return

	test "return true for Any", ->
		expect(isAny(Any)).toBe(true)

	test "return true for Any()", ->
		expect(isAny(Any())).toBe(true)

describe "isEmptyObject", ->

	test "return true for empty object", ->
		expect(isEmptyObject({})).toBe(true)

	test "return false for non-empty object values", ->
		expect(isEmptyObject({a: 1})).toBe(false)
		expect(isEmptyObject({a: {}})).toBe(false)
		expect(isEmptyObject({a: 1, b: 2})).toBe(false)
		expect(isEmptyObject({a: {}, b: {}})).toBe(false)

