import {fn, Any} from '../../dist'

test "return an error with 'undefined or null'", ->
	f = fn [undefined, null], Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'undefined or null', got Boolean true.")

test "return an error with 'String or Number'", ->
	f = fn [String, Number], Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'String or Number', got Boolean true.")

test "return an error with 'literal 'foo' or literal 'bar''", ->
	f = fn ['foo', 'bar'], Any, ->
	expect(-> f('a'))
	.toThrow("Expected argument #1 to be
				'literal String \"foo\" or literal String \"bar\"', got String \"a\".")

test "return an error with 'literal Number 1 or literal Number 2'", ->
	f = fn [1, 2], Any, ->
	expect(-> f(3))
	.toThrow("Expected argument #1 to be
				'literal Number 1 or literal Number 2', got Number 3.")

test "return an error with 'literal String \"1\" or literal Number '1'", ->
	f = fn ['1', 1], Any, ->
	expect(-> f(3))
	.toThrow("Expected argument #1 to be
				'literal String \"1\" or literal Number 1', got Number 3.")

test "return an error with 'literal Boolean true or literal Boolean false", ->
	f = fn [true, false], Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be
				'literal Boolean true or literal Boolean false', got Number 1.")
