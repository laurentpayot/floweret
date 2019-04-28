import {isValid} from '../../dist'

test "return true only for a regular expression value when type is RegExp", ->
	expect(isValid(RegExp, /foo/)).toBe(true)
	expect(isValid(RegExp, "foo")).toBe(false)

test "test the value when type is a regular expression instance", ->
	expect(isValid(/foo/, "foo")).toBe(true)
	expect(isValid(/foo/, "bar")).toBe(false)
	expect(isValid(/foo/, "")).toBe(false)
	expect(isValid(/foo/, /foo/)).toBe(false)
	expect(isValid(/foo/, 1)).toBe(false)
