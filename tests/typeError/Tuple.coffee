import {fn, Any} from '../../dist'
import Tuple from '../../dist/types/Tuple'
import Type from '../../dist/types/Type'

test "return an error with 'tuple of 3 elements 'Number, Boolean, String''", ->
	f = fn Tuple(Number, Boolean, String), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be
			tuple of 3 elements 'Number, Boolean, String', got Number 1.")

test "return an error with 'tuple of 3 elements 'Number, Object or null, String''", ->
	f = fn Tuple(Number, [Object, null], String), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be
			tuple of 3 elements 'Number, Object or null, String', got Number 1.")

test "return an error with 'tuple of 3 elements 'Number, Boolean, String''", ->
	f = fn Tuple(Number, Boolean, String), Any, ->
	expect(-> f([1, 2, "three"]))
	.toThrow("Expected argument #1 tuple element 1 to be Boolean, got Number 2")

test "alias for invalid type", ->
	f = fn Tuple(Number, Boolean, String).alias("Trio"), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Trio:
			tuple of 3 elements 'Number, Boolean, String', got Boolean true.")

test "alias for invalid Tuple", ->
	f = fn Tuple(Number, Boolean, String).alias("Trio"), Any, ->
	expect(-> f([1, 2, "three"]))
	.toThrow("Expected argument #1 Trio tuple element 1 to be Boolean, got Number 2.")
