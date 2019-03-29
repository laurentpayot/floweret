import {fn, Any} from '../../dist'
import constraint from '../../dist/types/constraint'

test "return an error with ''constraint' argument must be a function.'", ->
	expect(-> constraint(1)).toThrow("'constraint' argument must be a function.")

test "return an error with 'constraint 'val => Number.isInteger(val)''", ->
	Int = constraint((val) -> Number.isInteger(val))
	f = fn Int, Number,
		(n) -> 1
	expect(-> f(2.5))
	.toThrow(
		/^Expected argument #1 to be 'constrained by 'function \(val\).\{[^$]+\}'', got Number 2\.5\.$/
	)
