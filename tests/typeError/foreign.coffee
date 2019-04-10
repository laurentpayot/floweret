import {fn, Any} from '../../dist'
import foreign from '../../dist/types/foreign'


test "foreign type by name", ->
	f = fn foreign('Foo'), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be foreign type Foo, got Boolean true.")

test "foreign type by typed properties", ->
	f = fn foreign({a: Number}), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be foreign type with typed properties, got Boolean true.")

test "foreign type by name alias", ->
	f = fn foreign('Bar').as("Foo"), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo, got Boolean true.")

test "foreign type by typed properties alias", ->
	f = fn foreign({a: Number}).as("Foo"), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo, got Boolean true.")
