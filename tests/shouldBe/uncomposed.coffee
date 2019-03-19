import {fn, Any} from '../../src'

test "return an error with 'undefined'", ->
	f = fn undefined, Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'undefined' instead of Number 1.")

test "return an error with 'null'", ->
	f = fn null, Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'null' instead of Number 1.")

test "return an error with 'String'", ->
	f = fn String, Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'String' instead of Number 1.")

test "return an error with
	'Argument number 1 should be of type 'Number' instead of Array.'", ->
	f = fn Number, Any, ->
	expect(-> f([1, 2]))
	.toThrow("Argument #1 should be of type 'Number' instead of Array.")

test "return an error with 'Array'", ->
	f = fn Array, Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'Array' instead of Number 1.")

test "return an error with 'literal String 'foo'", ->
	f = fn 'foo', Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'literal String \"foo\"' instead of Number 1.")

test "return an error with 'literal Number 1'", ->
	f = fn 1, Any, ->
	expect(-> f('1'))
	.toThrow("Argument #1 should be of type 'literal Number 1' instead of String \"1\".")

test "return an error with 'literal Boolean 'true'", ->
	f = fn true, Any, ->
	expect(-> f(false))
	.toThrow("Argument #1 should be of type 'literal Boolean true' instead of Boolean false.")

test "return an error with
	'Argument number 1 should be of type 'Number' instead of Object.'", ->
	f = fn Number, Any, ->
	expect(-> f(a: {b: 1, c: 2}, d: 3))
	.toThrow("Argument #1 should be of type 'Number' instead of Object.")

test "return an error with
	'Argument number 1 should be an object with key 'a.c' of type 'String' instead of Number 2.'", ->
	f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
	expect(-> f(a: {b: 1, c: 2}, d: 3))
	.toThrow("Argument #1 should be an object with key 'a.c' of type 'String' instead of Number 2.")

test "return an error with
	'Argument number 1 should be an object with key 'a.c' of type 'String' instead of missing key 'c'.'", ->
	f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
	expect(-> f(a: {b: 1, x: 4}, d: 3))
	.toThrow("Argument #1 should be an object with key 'a.c' of type 'String' instead of missing key 'c'.")

test "return an error with
	'Argument number 1 should be an object with key 'a.c' of type 'String' instead of undefined.'", ->
	f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
	expect(-> f(a: {b: 1, c: undefined, x: 4}, d: 3))
	.toThrow("Argument #1 should be an object with key 'a.c' of type 'String' instead of undefined.")

test "return an error with
	'Argument number 1 should be an object with key 'a.c' of type 'String' instead of Number 5.'", ->
	f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
	expect(-> f(a: {b: 1, c: 5, x: 4}, d: 3))
	.toThrow("Argument #1 should be an object with key 'a.c' of type 'String' instead of Number 5.")

test "return an error with 'MyClass", ->
	class MyClass
	f = fn MyClass, Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'MyClass' instead of Number 1.")

test "return an error with 'array of'", ->
	f = fn Array(Number), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'array of 'Number'' instead of Number 1.")

test "return an error with 'array with element 1 of type 'Number' instead of String \"2\"'", ->
	f = fn Array(Number), Any, ->
	expect(-> f([1, '2', 3]))
	.toThrow("Argument #1 should be an array with element 1 of type 'Number' instead of String \"2\".")

test "return an error with 'array with a length of 4 instead of 3", ->
	f = fn Array(4), Any, ->
	expect(-> f([1, '2', 3]))
	.toThrow("Argument #1 should be an array with a length of 4 instead of 3.")

test "return an error with 'an array with a length of 2 instead of 3.", ->
	f = fn Array(2), Any, ->
	expect(-> f([1, '2', 3]))
	.toThrow("Argument #1 should be an array with a length of 2 instead of 3.")

test "return an error with 'of type 'Number or String' instead of Array", ->
	f = fn [Number, String], Any, ->
	expect(-> f([1]))
	.toThrow("Argument #1 should be of type 'Number or String' instead of Array.")

test "return an error with ''empty array' instead of Number 1.'", ->
	f = fn [], Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'empty array' instead of Number 1.")

test "return an error with 'empty array instead of a non-empty array'", ->
	f = fn [], Any, ->
	expect(-> f([1]))
	.toThrow("Argument #1 should be an empty array instead of a non-empty array.")

test "return an error with ''empty object' instead of Number 1.'", ->
	f = fn {}, Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'empty object' instead of Number 1.")

test "return an error with 'empty object instead of a non-empty object.'", ->
	f = fn {}, Any, ->
	expect(-> f({foo: "bar"}))
	.toThrow("Argument #1 should be an empty object instead of a non-empty object.")

test "return an error with 'NaN'", ->
	f = fn Number, Any, ->
	expect(-> f("a" * 2))
	.toThrow("Argument #1 should be of type 'Number' instead of NaN.")

test "return an error with 'RegExp'", ->
	f = fn /foo/, Any, ->
	expect(-> f("bar"))
	.toThrow("Argument #1 should be of type
				'string matching regular expression /foo/' instead of String \"bar\".")
