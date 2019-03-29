import {typed} from '../../dist'
import Tuple from '../../dist/types/Tuple'

test "init", ->
	Trio = Tuple(Number, Number, Number)
	t = typed Trio , [1, 2, 3]
	expect(t).toEqual([1, 2, 3])

test "set", ->
	Trio = Tuple(Number, Number, Number)
	t = typed Trio, [1, 2, 3]
	t[2] = 4
	expect(t).toEqual([1, 2, 4])

test "trow an error with a non-tuple type", ->
	Trio = Tuple(Number, Number, Number)
	expect(-> t = typed Trio, 1)
	.toThrow("Expected 'tuple of 3 elements 'Number, Number, Number'', got Number 1.")

test "trow an error with a mismatched tuple type", ->
	Trio = Tuple(Number, Number, Number)
	expect(-> t = typed Trio, [1, true, 3])
	.toThrow("Expected tuple element 1 to be 'Number', got Boolean true.")

test "trow an error with a too long tuple type", ->
	Trio = Tuple(Number, Number, Number)
	expect(-> t = typed Trio, [1, 2, 3, 4])
	.toThrow("Tuple must have a length of 3.")

test "trow an error for a push", ->
	Trio = Tuple(Number, Number, Number)
	t = typed Trio, [1, 2, 3]
	expect(-> t.push(4))
	.toThrow("Tuple must have a length of 3.")

test "trow an error for a delete", ->
	Trio = Tuple(Number, Number, Number)
	t = typed Trio, [1, 2, 3]
	expect(-> delete t[0])
	.toThrow("Tuple must have a length of 3.")

test "trow an error for a set type mismatch", ->
	Trio = Tuple(Number, Number, Number)
	t = typed Trio, [1, 2, 3]
	expect(-> t[1] = true)
	.toThrow("Expected tuple element 1 to be 'Number', got Boolean true.")

