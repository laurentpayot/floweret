import {fn, Any} from '../../src'

test "return a result error with ''Number' instead of NaN'", ->
	f = fn Number, [undefined, Number], Number,
		(a, b) -> a + b # missing default b value
	expect(-> f(1))
	.toThrow("Result should be of type 'Number' instead of NaN.")
