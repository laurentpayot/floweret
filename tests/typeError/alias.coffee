import {fn, Any} from '../../dist'
import alias from '../../dist/types/alias'
import Tuple from '../../dist/types/Tuple'

test "no alias name", ->
	expect(-> alias("", {a: Number}))
	.toThrow("Alias name must be a non-empty string.")
	expect(-> alias(undefined, {a: Number}))
	.toThrow("Alias name must be a non-empty string.")

test "object", ->
	f = fn alias('Foo', {a: Number}), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: object type, got Boolean true.")
	expect(-> f({a: 'foo'}))
	.toThrow("Expected argument #1 to be Foo: an object with key 'a' of type 'Number' instead of String \"foo\".")

test "object with an aliased type", ->
	Bar = alias "Bar", Number
	f = fn alias('Foo', {a: Bar}), Any, ->
	expect(-> f({a: 1})).not.toThrow()
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: object type, got Boolean true.")
	expect(-> f({a: 'foo'}))
	.toThrow("Expected argument #1 to be Foo: an object with key 'a' of type 'Bar' instead of String \"foo\".")

test "array", ->
	f = fn alias('Foo', Array(Number)), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: 'array of 'Number'', got Boolean true.")
	expect(-> f([1, true, 3]))
	.toThrow("Expected argument #1 to be Foo: an array with element 1 of type 'Number' instead of Boolean true.")

test "sized array", ->
	f = fn alias('Foo', Array(3)), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: 'array of 3 elements', got Boolean true.")
	expect(-> f([1, true, 'tree', NaN]))
	.toThrow("Expected argument #1 to be Foo: an array with a length of 3 instead of 4.")

test "array of an aliased type", ->
	Bar = alias "Bar", Number
	f = fn alias('Foo', Array(Bar)), Any, ->
	expect(-> f([1, 2, 3])).not.toThrow()
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: 'array of 'Bar'', got Boolean true.")
	expect(-> f([1, true, 3]))
	.toThrow("Expected argument #1 to be Foo: an array with element 1 of type 'Bar' instead of Boolean true.")

test "custom type (Tuple)", ->
	f = fn alias('Foo', Tuple(Number, Number)), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: tuple of 2 elements 'Number, Number', got Boolean true.")
	expect(-> f([1, true]))
	.toThrow("Expected argument #1 Foo tuple element 1 to be Number, got Boolean true.")

test "custom type (Tuple) with an aliased type", ->
	Bar = alias "Bar", Number
	f = fn alias('Foo', Tuple(Number, Bar)), Any, ->
	expect(-> f([1, 2])).not.toThrow()
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: tuple of 2 elements 'Number, Bar', got Boolean true.")
	expect(-> f([1, true]))
	.toThrow("Expected argument #1 Foo tuple element 1 to be Bar, got Boolean true.")
