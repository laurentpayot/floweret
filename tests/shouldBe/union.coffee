import {fn, Any} from '../../dist'

test "return an error with 'undefined or null'", ->
	f = fn [undefined, null], Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'undefined or null' instead of Boolean true.")

test "return an error with 'String or Number'", ->
	f = fn [String, Number], Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'String or Number' instead of Boolean true.")

test "return an error with 'literal 'foo' or literal 'bar''", ->
	f = fn ['foo', 'bar'], Any, ->
	expect(-> f('a'))
	.toThrow("Argument #1 should be of type
				'literal String \"foo\" or literal String \"bar\"' instead of String \"a\".")

test "return an error with 'literal Number 1 or literal Number 2'", ->
	f = fn [1, 2], Any, ->
	expect(-> f(3))
	.toThrow("Argument #1 should be of type
				'literal Number 1 or literal Number 2' instead of Number 3.")

test "return an error with 'literal String \"1\" or literal Number '1'", ->
	f = fn ['1', 1], Any, ->
	expect(-> f(3))
	.toThrow("Argument #1 should be of type
				'literal String \"1\" or literal Number 1' instead of Number 3.")

test "return an error with 'literal Boolean true or literal Boolean false", ->
	f = fn [true, false], Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type
				'literal Boolean true or literal Boolean false' instead of Number 1.")
