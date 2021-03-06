import {fn, Any} from '../../dist'

test "return an error with 'undefined'", ->
	f = fn undefined, Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be undefined, got Number 1.")

test "return an error with 'null'", ->
	f = fn null, Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be null, got Number 1.")

test "return an error with 'String'", ->
	f = fn String, Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be String, got Number 1.")

test "return an error with
	'Argument number 1 should be of type 'Number, got Array of 2 elements.'", ->
	f = fn Number, Any, ->
	expect(-> f([1, 2]))
	.toThrow("Expected argument #1 to be Number, got Array of 2 elements.")

test "return an error with 'Array'", ->
	f = fn Array, Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be Array, got Number 1.")

test "return an error with 'literal String 'foo'", ->
	f = fn 'foo', Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be literal String \"foo\", got Number 1.")

test "return an error with 'literal Number 1'", ->
	f = fn 1, Any, ->
	expect(-> f('1'))
	.toThrow("Expected argument #1 to be literal Number 1, got String \"1\".")

test "return an error with 'literal Boolean 'true'", ->
	f = fn true, Any, ->
	expect(-> f(false))
	.toThrow("Expected argument #1 to be literal Boolean true, got Boolean false.")

test "return an error with
	'Argument number 1 should be of type 'Number, got Object.'", ->
	f = fn Number, Any, ->
	expect(-> f(a: {b: 1, c: 2}, d: 3))
	.toThrow("Expected argument #1 to be Number, got Object.")

test "return an error with 'MyClass", ->
	class MyClass
	f = fn MyClass, Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be MyClass, got Number 1.")

test "return an error with 'of type 'Number or String, got Array of 1 elements", ->
	f = fn [Number, String], Any, ->
	expect(-> f([1]))
	.toThrow("Expected argument #1 to be Number or String, got Array of 1 elements.")


test "return an error with 'NaN'", ->
	f = fn Number, Any, ->
	expect(-> f("a" * 2))
	.toThrow("Expected argument #1 to be Number, got NaN.")

test "return an error with 'RegExp'", ->
	f = fn /foo/, Any, ->
	expect(-> f("bar"))
	.toThrow("Expected argument #1 to be
				string matching regular expression /foo/, got String \"bar\".")
