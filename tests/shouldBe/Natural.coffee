import {fn, Any} from '../../src'
import Natural from '../../src/types/Natural'

test "return an error with 'Natural'", ->
	f = fn Natural, Any, ->
	expect(-> f(true)).toThrow("Argument #1 should be of type 'Natural' instead of Boolean true.")

test "return an error with 'Natural smaller than 100'", ->
	f = fn Natural(100), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'Natural smaller than 100' instead of Boolean true.")

test "return an error with 'Natural bigger than 100'", ->
	f = fn Natural(100, undefined), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'Natural bigger than 100' instead of Boolean true.")

test "return an error with 'Natural bigger than 10 and smaller than 100'", ->
	f = fn Natural(10, 100), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'Natural bigger than 10
				and smaller than 100' instead of Boolean true.")

test "return an error with ''Natural' arguments must be positive numbers.'", ->
	expect(-> Natural(-100, -10)).toThrow("'Natural' arguments must be positive numbers.")
	expect(-> Natural(-100, 10)).toThrow("'Natural' arguments must be positive numbers.")

test "return an error with ''Natural' max value cannot be less than min value", ->
	expect(-> Natural(100, -100))
	.toThrow("'Natural' max value cannot be less than min value.")
