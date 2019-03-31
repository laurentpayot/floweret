import {fn, Any} from '../../dist'
import And from '../../dist/types/and'
import Not from '../../dist/types/not'

# NB: Or() returns an array, not an Or instance, see array tests

describe "And", ->

	test "return an error with ''array of 'Number'' and 'array of 3 elements''", ->
		f = fn And(Array(Number), Array(3)), Any, ->
		expect(-> f(1))
		.toThrow("Expected argument #1 to be
					'array of 'Number'' and 'array of 3 elements', got Number 1.")

describe "Not", ->

	test "return an error with 'not 'Number''", ->
		f = fn Not(Number), Any, ->
		expect(-> f(1))
		.toThrow("Expected argument #1 to be not 'Number', got Number 1.")

	test "return an error with 'not 'Number or array of 'Number'''", ->
		f = fn Not([Number, Array(Number)]), Any, ->
		expect(-> f(1))
		.toThrow("Expected argument #1 to be
				not 'Number or 'array of 'Number''', got Number 1.")
