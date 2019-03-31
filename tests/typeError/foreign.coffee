import {fn, Any} from '../../dist'
import foreign from '../../dist/types/foreign'


test "return an error with 'foreign type'", ->
	f = fn foreign('Foo'), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be foreign type Foo, got Boolean true.")

test "return an error with 'foreign type with typed properties'", ->
	f = fn foreign({a: Number}), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be foreign type with typed properties, got Boolean true.")

