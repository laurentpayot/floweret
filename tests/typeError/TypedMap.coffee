import {fn, Any} from '../../dist'
import TypedMap from '../../dist/types/TypedMap'

test "return an error with 'map with values of type 'Number''", ->
	f = fn TypedMap(Number), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be map with values of type 'Number', got Number 1.")

test "return an error with 'map element value to be String, got Number 2.'", ->
	f = fn TypedMap(String), Any, ->
	expect(-> f(new Map([[1, 'foo'], [2, 2]])))
	.toThrow("Expected argument #1 map element value to be String, got Number 2.")

test "return an error with 'map with keys of type 'Number' and values of type 'String''", ->
	f = fn TypedMap(Number, String), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be
			map with keys of type 'Number' and values of type 'String', got Number 1.")

test "return an error with 'map element key to be Number, got String \"two\".'", ->
	f = fn TypedMap(Number, String), Any, ->
	expect(-> f(new Map([[1, 'foo'], ['two', 'bar']])))
	.toThrow("Expected argument #1 map element key to be Number, got String \"two\".")
