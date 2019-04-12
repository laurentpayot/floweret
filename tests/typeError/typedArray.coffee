import {fn, Any} from '../../dist'
import alias from '../../dist/types/alias'

test "return an error with 'array of 'Number''", ->
	f = fn Array(Number), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be 'array of 'Number'', got Number 1.")

test "return an error with 'array of 'Promise''", ->
	f = fn Array(Promise), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be 'array of 'Promise'', got Number 1.")

test "return an error with 'array of 'String or Number''", ->
	f = fn Array([String, Number]), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be 'array of 'String or Number'', got Number 1.")

test "return an error with 'array of 'object type object''", ->
	f = fn Array({a: String, b: Number}), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be 'array of 'object type'', got Number 1.")

test "Array(Any) should return an error with 'array of 'any type''", ->
	f = fn Array(Any), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be 'array of 'any type'', got Number 1.")

test "Array(Any)] should return an error with 'array of 'any type''", ->
	f = fn Array(Any), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be 'array of 'any type'', got Number 1.")

test "Array(Any()) should return an error with 'array of 'any type''", ->
	f = fn Array(Any()), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be 'array of 'any type'', got Number 1.")

test "Array(Number) should return an error with 'array with element 2 of type 'Number' instead of String.'", ->
	f = fn Array(Number), Any, ->
	expect(-> f([1, 2, "three", 4]))
	.toThrow("Expected argument #1 to be an array with element 2 of type 'Number' instead of String \"three\".")

test "Array(Number) should return an error with
	'array with element 0 of type 'Number or String' instead of Boolean true.'", ->
	f = fn Array([Number, String]), Any, ->
	expect(-> f([true]))
	.toThrow("Expected argument #1 to be an array with element 0 of type
				'Number or String' instead of Boolean true.")

test "alias for invalid type", ->
	f = fn alias("Foo", Array(Number)), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: 'array of 'Number'', got Boolean true.")

test "alias for invalid array", ->
	f = fn alias("Foo", Array(Number)), Any, ->
	expect(-> f([1, true, 3]))
	.toThrow("Expected argument #1 to be Foo: an array with element 1 of type 'Number' instead of Boolean true.")
