import {fn, Any} from '../../dist'
import constraint from '../../dist/types/constraint'

test "return an error with ''constraint' argument must be a function.'", ->
	expect(-> constraint(1)).toThrow("'constraint' argument must be a function.")

test "return an error with function name", ->
	Int = constraint(Number.isInteger)
	f = fn Int, Number,
		(n) -> 1
	expect(-> f(2.5))
	.toThrow("Expected argument #1 to be constrained by function 'isInteger', got Number 2.5.")

test "return an error with function code", ->
	Int = constraint((val) -> val < 3)
	f = fn Int, Number,
		(n) -> 1
	expect(-> f(3.5))
	.toThrow(/^Expected argument #1 to be constrained by 'function \(val\).\{[^$]+\}', got Number 3\.5\.$/)

test "alias", ->
	Int = constraint(Number.isInteger).as("Integer")
	f = fn Int, Number,
		(n) -> 1
	expect(-> f(2.5))
	.toThrow("Expected argument #1 to be Integer: constrained type, got Number 2.5.")
