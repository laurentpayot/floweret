import {check, fn, Any} from '../../dist'
import TypedSet from '../../dist/types/TypedSet'

test "init", ->
	s = check TypedSet(Number), new Set([1, 2, 3])
	expect([s...]).toEqual([1, 2, 3])

test "add", ->
	s = check TypedSet(Number), new Set([1, 2, 3])
	s.add(4)
	expect([s...]).toEqual([1, 2, 3,4])

test "trow an error with a non-TypedSet type", ->
	expect(-> s = check TypedSet(Number), 1)
	.toThrow("Expected set of 'Number', got Number 1.")

test "trow an error with a mismatched TypedSet type", ->
	expect(-> s = check TypedSet(Number), new Set([1, true, 3]))
	.toThrow("Expected set element to be Number, got Boolean true.")

test "trow an error for a add type mismatch", ->
	s = check TypedSet(Number), new Set([1, 2, 3])
	expect(-> s.add(true))
	.toThrow("Expected set element to be Number, got Boolean true.")

test "set types are stored in TypedSet instances so they do not overwrite", ->
	s1 = check TypedSet(Number), new Set([1, 2, 3])
	s2 = check TypedSet(String), new Set(['one', 'two', 'three'])
	expect(-> s1.add(4)).not.toThrow()

describe "alias", -> # TODO !!!

describe "fn auto-typing", ->

	test "input parameter side effects", ->
		f = fn Boolean, TypedSet(Number), Any, Any,
			(foo, bar, baz) -> bar.add(baz)
		s = new Set([1, 2, 3])
		expect([f(true, s, 4)...]).toEqual([1, 2, 3, 4])
		expect([s...]).toEqual([1, 2, 3, 4])

	test "input parameter no side effects when invalid", ->
		f = fn Boolean, TypedSet(Number), Any, Any,
			(foo, bar, baz) -> bar.add(baz)
		s = new Set([1, 2, 3])
		expect(-> f(true, s, true))
		.toThrow("Expected set element to be Number, got Boolean true.")
		expect([s...]).toEqual([1, 2, 3])

	test "input parameter was not checkWrapped", ->
		f = fn Boolean, TypedSet(Number), Any, Any,
			(foo, bar, baz) -> bar.add(baz)
		s = new Set([1, 2, 3])
		expect([f(true, s, 4)...]).toEqual([1, 2, 3, 4])
		expect([s...]).toEqual([1, 2, 3, 4])
		expect(-> s.add(false)).not.toThrow()
		expect([s...]).toEqual([1, 2, 3, 4, false])

	# TODO: result and etc() tests!!!
