import {fn, Any} from '../../dist'
import TypedObject from '../../dist/types/TypedObject'

test "return an error with 'object with values of type 'Number''", ->
	f = fn TypedObject(Number), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'object with values of type 'Number'' instead of Number 1.")

test "return an error with 'set of 'String''", ->
	f = fn TypedObject(String), Any, ->
	expect(-> f({a: 'foo', b: 1}))
	.toThrow("Argument #1 should be of type 'object with values of type 'String'' instead of Object.")
