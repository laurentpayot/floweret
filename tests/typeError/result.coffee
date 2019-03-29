import {fn, Any} from '../../dist'

test "return a result error with ''Number', got NaN'", ->
	f = fn Number, [undefined, Number], Number,
		(a, b) -> a + b # missing default b value
	expect(-> f(1))
	.toThrow("Expected result to be 'Number', got NaN.")
