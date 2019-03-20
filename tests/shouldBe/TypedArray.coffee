import {fn, Any} from '../../dist'

test "return an error with 'array of 'Number''", ->
	f = fn Array(Number), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'array of 'Number'' instead of Number 1.")

test "return an error with 'array of 'Promise''", ->
	f = fn Array(Promise), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'array of 'Promise'' instead of Number 1.")

test "return an error with 'array of 'String or Number''", ->
	f = fn Array([String, Number]), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'array of 'String or Number'' instead of Number 1.")

test "return an error with 'array of 'object type object''", ->
	f = fn Array({a: String, b: Number}), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'array of 'object type'' instead of Number 1.")

it "Array(Any) should return an error with 'array of 'any type''", ->
	f = fn Array(Any), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'array of 'any type'' instead of Number 1.")

it "Array(Any)] should return an error with 'array of 'any type''", ->
	f = fn Array(Any), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'array of 'any type'' instead of Number 1.")

it "Array(Any()) should return an error with 'array of 'any type''", ->
	f = fn Array(Any()), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'array of 'any type'' instead of Number 1.")

it "Array(Number) should return an error with 'array with element 2 of type 'Number' instead of String.'", ->
	f = fn Array(Number), Any, ->
	expect(-> f([1, 2, "three", 4]))
	.toThrow("Argument #1 should be an array with element 2 of type 'Number' instead of String \"three\".")

it "Array(Number) should return an error with
	'array with element 0 of type 'Number or String' instead of Boolean.'", ->
	f = fn Array([Number, String]), Any, ->
	expect(-> f([true]))
	.toThrow("Argument #1 should be an array with element 0 of type
				'Number or String' instead of Boolean true.")
