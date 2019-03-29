import {fn, Any} from '../../dist'
import Integer from '../../dist/types/Integer'

test "return an error with 'Integer'", ->
	f = fn Integer, Any, ->
	expect(-> f(true)).toThrow("Expected argument #1 to be 'Integer', got Boolean true.")

test "return an error with 'Integer bigger than or equal to 0 and smaller than or equal to 100'", ->
	f = fn Integer(100), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'Integer bigger than or equal to 0
			and smaller than or equal to 100', got Boolean true.")

test "return an error with 'Integer bigger than or equal to 100'", ->
	f = fn Integer(100, undefined), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'Integer bigger than or equal to 100', got Boolean true.")

test "return an error with 'Integer smaller than or equal to 100'", ->
	f = fn Integer(undefined, 100), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'Integer smaller than or equal to 100', got Boolean true.")

test "return an error with 'Integer bigger than or equal to 10 and smaller than or equal to 100'", ->
	f = fn Integer(10, 100), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'Integer bigger than or equal to 10
				and smaller than or equal to 100', got Boolean true.")

test "return an error with 'Integer bigger than or equal to -100 and smaller than or equal to -10'", ->
	f = fn Integer(-100, -10), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'Integer bigger than or equal to -100
				and smaller than or equal to -10', got Boolean true.")

test "return an error with 'Integer bigger than or equal to -100 and smaller than or equal to 10'", ->
	f = fn Integer(-100, 10), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'Integer bigger than or equal to -100
				and smaller than or equal to 10', got Boolean true.")

test "return an error with ''Integer' max value cannot be less than min value", ->
	expect(-> Integer(100, -100))
	.toThrow("'Integer' max value cannot be less than min value.")
