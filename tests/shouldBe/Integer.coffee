import {fn, Any} from '../../src'
import Integer from '../../src/types/Integer'

test "return an error with 'Integer'", ->
	f = fn Integer, Any, ->
	expect(-> f(true)).toThrow("Argument #1 should be of type 'Integer' instead of Boolean true.")

test "return an error with 'Integer smaller than 100'", ->
	f = fn Integer(100), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'Integer smaller than 100' instead of Boolean true.")

test "return an error with 'Integer bigger than 100'", ->
	f = fn Integer(100, undefined), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'Integer bigger than 100' instead of Boolean true.")

test "return an error with 'Integer bigger than 10 and smaller than 100'", ->
	f = fn Integer(10, 100), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'Integer bigger than 10
				and smaller than 100' instead of Boolean true.")

test "return an error with 'Integer bigger than -100 and smaller than -10'", ->
	f = fn Integer(-100, -10), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'Integer bigger than -100
				and smaller than -10' instead of Boolean true.")

test "return an error with 'Integer bigger than -100 and smaller than 10'", ->
	f = fn Integer(-100, 10), Any, ->
	expect(-> f(true))
	.toThrow("Argument #1 should be of type 'Integer bigger than -100
				and smaller than 10' instead of Boolean true.")

test "return an error with ''Integer' max value cannot be less than min value", ->
	expect(-> Integer(100, -100))
	.toThrow("'Integer' max value cannot be less than min value.")
