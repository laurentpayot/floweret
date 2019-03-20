import {fn, Any} from '../../dist'
import TypedSet from '../../dist/types/TypedSet'

test "return an error with 'set of 'Number''", ->
	f = fn TypedSet(Number), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'set of 'Number'' instead of Number 1.")

test "return an error with 'set of 'String''", ->
	f = fn TypedSet(String), Any, ->
	expect(-> f(new Set(['a', 1])))
	.toThrow("Argument #1 should be of type 'set of 'String'' instead of Set.")
