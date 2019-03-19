import {fn, Any} from '../../src'
import TypedMap from '../../src/types/TypedMap'

test "return an error with 'map with values of type 'Number''", ->
	f = fn TypedMap(Number), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type 'map with values of type 'Number'' instead of Number 1.")

test "return an error with 'map with values of type 'String''", ->
	f = fn TypedMap(String), Any, ->
	expect(-> f(new Map([[1, 'foo'], [2, 2]])))
	.toThrow("Argument #1 should be of type 'map with values of type 'String'' instead of Map.")

test "return an error with 'map with keys of type 'Number' and values of type 'String''", ->
	f = fn TypedMap(Number, String), Any, ->
	expect(-> f(1))
	.toThrow("Argument #1 should be of type
				'map with keys of type 'Number' and values of type 'String'' instead of Number 1.")

test "return an error with
			''map with keys of type 'Number' and values of type 'String'' instead of Map.'", ->
	f = fn TypedMap(Number, String), Any, ->
	expect(-> f(new Map([[1, 'foo'], ['two', 'bar']])))
	.toThrow("Argument #1 should be of type
				'map with keys of type 'Number' and values of type 'String'' instead of Map.")
