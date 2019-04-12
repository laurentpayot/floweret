import {fn, Any} from '../../dist'
import alias from '../../dist/types/alias'


test "empty array", ->
	f = fn Array(3), Any, ->
	expect(-> f([]))
	.toThrow("Expected argument #1 to be an array with a length of 3 instead of 0.")

test "different size array of Number", ->
	f = fn Array(3), Any, ->
	expect(-> f([1, 2]))
	.toThrow("Expected argument #1 to be an array with a length of 3 instead of 2.")

test "different size array of undefined", ->
	f = fn Array(3), Any, ->
	expect(-> f([undefined, undefined]))
	.toThrow("Expected argument #1 to be an array with a length of 3 instead of 2.")

test "empty array type with non-array value", ->
	f = fn [], Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be empty array, got Number 1.")

test "empty array type with non-empty array value", ->
	f = fn [], Any, ->
	expect(-> f([1]))
	.toThrow("Expected argument #1 to be an empty array, got a non-empty array.")

test "alias for invalid type", ->
	f = fn alias("Foo", Array(3)), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: 'array of 3 elements', got Boolean true.")

test "alias for invalid array", ->
	f = fn alias("Foo", Array(3)), Any, ->
	expect(-> f([1, 2]))
	.toThrow("Expected argument #1 to be Foo: an array with a length of 3 instead of 2.")
