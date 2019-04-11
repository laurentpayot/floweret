import {fn, Any} from '../../dist'
import TypedObject from '../../dist/types/TypedObject'

test "return an error with 'object with values of type 'Number''", ->
	f = fn TypedObject(Number), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be object with values of type 'Number', got Number 1.")

test "return an error with 'object property 'b' to be String'", ->
	f = fn TypedObject(String), Any, ->
	expect(-> f({a: 'foo', b: 1}))
	.toThrow("Expected argument #1 object property 'b' to be String, got Number 1.")

test "alias for invalid type", ->
	f = fn TypedObject(Number).as("Foo"), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: object with values of type 'Number', got Boolean true.")

test "alias for invalid array", ->
	f = fn TypedObject(Number).as("Foo"), Any, ->
	expect(-> f({a: true}))
	.toThrow("Expected argument #1 Foo object property 'a' to be Number, got Boolean true.")
