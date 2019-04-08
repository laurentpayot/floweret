import {typed} from '../../dist'
import TypedMap from '../../dist/types/TypedMap'

describe "values type", ->

	test "init", ->
		m = typed TypedMap(Number), new Map([[1,1], [2,2], [3,3]])
		expect([m...]).toEqual([[1,1], [2,2], [3,3]])

	test "add", ->
		m = typed TypedMap(Number), new Map([[1,1], [2,2], [3,3]])
		m.set(4,4)
		expect([m...]).toEqual([[1,1], [2,2], [3,3], [4,4]])

	test "trow an error with a non-TypedMap type", ->
		expect(-> m = typed TypedMap(Number), 1)
		.toThrow("Expected map with values of type 'Number', got Number 1.")

	test "trow an error with a mismatched TypedMap value type", ->
		expect(-> m = typed TypedMap(Number), new Map([[1,1], [2,true], [3,3]]))
		.toThrow("Expected map element value to be Number, got Boolean true.")

	test "trow an error for a set value type mismatch", ->
		m = typed TypedMap(Number), new Map([[1,1], [2,2], [3,3]])
		expect(-> m.set(4, true))
		.toThrow("Expected map element value to be Number, got Boolean true.")

	test "set types are stored in TypedMap instances so they do not overwrite", ->
		m1 = typed TypedMap(Number), new Map([[1,1], [2,2], [3,3]])
		m2 = typed TypedMap(String), new Map([[1,'one'], [2,'two'], [3,'three']])
		expect(-> m1.set(4,4)).not.toThrow()
	
describe "keys type and values type", ->

	test "init", ->
		m = typed TypedMap(Number, String), new Map([[1,'1'], [2,'2'], [3,'3']])
		expect([m...]).toEqual([[1,'1'], [2,'2'], [3,'3']])

	test "set", ->
		m = typed TypedMap(Number, String), new Map([[1,'1'], [2,'2'], [3,'3']])
		m.set(4,'4')
		expect([m...]).toEqual([[1,'1'], [2,'2'], [3,'3'], [4,'4']])

	test "trow an error with a non-TypedMap type", ->
		expect(-> m = typed TypedMap(Number, String), 1)
		.toThrow("Expected map with keys of type 'Number' and values of type 'String', got Number 1.")

	test "trow an error with a mismatched TypedMap key type", ->
		expect(-> m = typed TypedMap(Number, String), new Map([[1,'1'], [true,'2'], [3,'3']]))
		.toThrow("Expected map element key to be Number, got Boolean true.")

	test "trow an error for a set key type mismatch", ->
		m = typed TypedMap(Number, String), new Map([[1,'1'], [2,'2'], [3,'3']])
		expect(-> m.set(true, '4'))
		.toThrow("Expected map element key to be Number, got Boolean true.")

	test "set types are stored in TypedMap instances so they do not overwrite", ->
		m1 = typed TypedMap(Number, String), new Map([[1,'1'], [2,'2'], [3,'3']])
		m2 = typed TypedMap(String, Number), new Map([['one',1], ['two',2], ['three',3]])
		expect(-> m1.set(4,'4')).not.toThrow()