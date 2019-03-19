import {fn, Any} from '../../src'
import foreign from '../../src/types/foreign'


test "return an error with 'foreign type'", ->
	f = fn foreign('Foo'), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'foreign type Foo' instead of Boolean true.")

test "return an error with 'foreign type with typed properties'", ->
	f = fn foreign({a: Number}), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'foreign type with typed properties' instead of Boolean true.")

