import {isValid} from '../../src'

test "return true only for a regular expression value when type is RegExp", ->
	expect(isValid(/foo/, RegExp)).toBe(true)
	expect(isValid("foo", RegExp)).toBe(false)

test "test the value when type is a regular expression instance", ->
	expect(isValid("foo", /foo/)).toBe(true)
	expect(isValid("bar", /foo/)).toBe(false)
	expect(isValid("", /foo/)).toBe(false)
	expect(isValid(/foo/, /foo/)).toBe(false)
	expect(isValid(1, /foo/)).toBe(false)
