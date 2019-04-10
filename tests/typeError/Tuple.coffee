import {fn, Any} from '../../dist'
import Tuple from '../../dist/types/Tuple'

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
	expect(-> f(Tuple(1, 2, "three")))
	.toThrow("Expected argument #1 to be tuple of 3 elements 'Number, Boolean, String', got Tuple.")

test "alias", ->
	f = fn Tuple(Number, Boolean, String).as("Trio"), Any, ->
	expect(-> f(Tuple(1, 2, "three")))
	.toThrow("Expected argument #1 to be Trio, got Tuple.")
