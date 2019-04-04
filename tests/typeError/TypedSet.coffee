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
