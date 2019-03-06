import {typeOf} from '../src'

describe "typeOf", ->

	# TODO: add more tests

	test "return 'NaN' for NaN", ->
		expect(typeOf(NaN)).toBe('NaN')

	test "return 'Object' for an object value, something else otherwise", ->
		expect(typeOf({})).toBe('Object')
		expect(typeOf({a: 1})).toBe('Object')
		expect(typeOf({a: 1, b: {c: 1}})).toBe('Object')
		expect(typeOf(null)).not.toBe('Object')
		expect(typeOf(undefined)).not.toBe('Object')
		expect(typeOf([])).not.toBe('Object')
		expect(typeOf([1])).not.toBe('Object')
		expect(typeOf(Object)).not.toBe('Object')
		expect(typeOf(-> {})).not.toBe('Object')

	test "return 'Function' for a function value, something else otherwise", ->
		expect(typeOf(->)).toBe('Function')
		expect(typeOf(-> 1)).toBe('Function')
		expect(typeOf(Function)).toBe('Function')
		expect(typeOf(String)).toBe('Function')
		expect(typeOf(Number)).toBe('Function')
		expect(typeOf(Array)).toBe('Function')
		expect(typeOf(Object)).toBe('Function')
		expect(typeOf(null)).not.toBe('Function')
		expect(typeOf(undefined)).not.toBe('Function')

	# test "return 'Object' for an object value even after Object.name modification", ->
	# 	Object.name = "foo"
	# 	expect(typeOf({})).toBe('Object')

	# test "return 'Function' for an Function value even after Function.name modification", ->
	# 	Function.name = "foo"
	# 	expect(typeOf(->)).toBe('Function')
