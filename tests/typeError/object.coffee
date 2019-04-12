import {fn, Any} from '../../dist'
import type from '../../dist/types/type'

test "return an error with
	'Argument number 1 should be an object with key 'a.c' of type 'String' instead of Number 2.'", ->
	f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
	expect(-> f(a: {b: 1, c: 2}, d: 3))
	.toThrow("Expected argument #1 to be an object with key 'a.c' of type 'String' instead of Number 2.")

test "return an error with
	'Argument number 1 should be an object with key 'a.c' of type 'String' instead of missing key 'c'.'", ->
	f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
	expect(-> f(a: {b: 1, x: 4}, d: 3))
	.toThrow("Expected argument #1 to be an object with key 'a.c' of type 'String' instead of missing key 'c'.")

test "return an error with
	'Argument number 1 should be an object with key 'a.c' of type 'String' instead of undefined.'", ->
	f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
	expect(-> f(a: {b: 1, c: undefined, x: 4}, d: 3))
	.toThrow("Expected argument #1 to be an object with key 'a.c' of type 'String' instead of undefined.")

test "return an error with
	'Argument number 1 should be an object with key 'a.c' of type 'String' instead of Number 5.'", ->
	f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
	expect(-> f(a: {b: 1, c: 5, x: 4}, d: 3))
	.toThrow("Expected argument #1 to be an object with key 'a.c' of type 'String' instead of Number 5.")

test "return an error with 'empty object, got Number 1.'", ->
	f = fn {}, Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be empty object, got Number 1.")

test "return an error with 'empty object, got a non-empty object.'", ->
	f = fn {}, Any, ->
	expect(-> f({foo: "bar"}))
	.toThrow("Expected argument #1 to be an empty object, got a non-empty object.")

test "alias for invalid type", ->
	f = fn type({a: {b: Number, c: String}, d: Number}).as("Foo"), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: object type, got Boolean true.")

test "alias for invalid array", ->
	f = fn type({a: {b: Number, c: String}, d: Number}).as("Foo"), Any, ->
	expect(-> f({a: {b: 1, c: true}, d: 3}))
	.toThrow("Expected argument #1 to be Foo:
			an object with key 'a.c' of type 'String' instead of Boolean true.")
