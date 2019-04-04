import {typed} from '../../dist'
import TypedSet from '../../dist/types/TypedSet'

test "init", ->
	s = typed TypedSet(Number), new Set([1, 2, 3])
	expect([s...]).toEqual([1, 2, 3])

test "add", ->
	s = typed TypedSet(Number), new Set([1, 2, 3])
	s.add(4)
	expect([s...]).toEqual([1, 2, 3,4])

test "trow an error with a non-TypedSet type", ->
	expect(-> s = typed TypedSet(Number), 1)
	.toThrow("Expected set of 'Number', got Number 1.")

test "trow an error with a mismatched TypedSet type", ->
	expect(-> s = typed TypedSet(Number), new Set([1, true, 3]))
	.toThrow("Expected set element to be Number, got Boolean true.")

test "trow an error for a add type mismatch", ->
	s = typed TypedSet(Number), new Set([1, 2, 3])
	expect(-> s.add(true))
	.toThrow("Expected set element to be Number, got Boolean true.")
