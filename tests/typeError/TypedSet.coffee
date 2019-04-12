import {fn, Any} from '../../dist'
import TypedSet from '../../dist/types/TypedSet'

test "return an error with 'set of 'Number''", ->
	f = fn TypedSet(Number), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be set of 'Number', got Number 1.")

test "return an error with 'set of 'String''", ->
	f = fn TypedSet(String), Any, ->
	expect(-> f(new Set(['a', 1])))
	.toThrow("Expected argument #1 set element to be String, got Number 1.")

test "alias for invalid type", ->
	f = fn TypedSet(Number).as("Foo"), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo: set of 'Number', got Boolean true.")

test "alias for invalid array", ->
	f = fn TypedSet(Number).as("Foo"), Any, ->
	expect(-> f(new Set([1, true, 3])))
	.toThrow("Expected argument #1 Foo set element to be Number, got Boolean true.")
