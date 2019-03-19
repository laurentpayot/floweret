import {fn, Any} from '../../src'
import Tuple from '../../src/types/Tuple'

test "return an error with 'tuple of 3 elements 'Number, Boolean, String''", ->
	f = fn Tuple(Number, Boolean, String), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'tuple of
				3 elements 'Number, Boolean, String'' instead of Number 1.")

test "return an error with 'tuple of 3 elements 'Number, Object or null, String''", ->
	f = fn Tuple(Number, [Object, null], String), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'tuple of
				3 elements 'Number, Object or null, String'' instead of Number 1.")
