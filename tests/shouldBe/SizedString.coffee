import {fn, Any} from '../../dist'
import SizedString from '../../dist/types/SizedString'

test "return an error with 'SizedString of at most 4 characters'", ->
	f = fn SizedString(100), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be
				'SizedString of at most 100 characters', got Boolean true.")

test "return an error with 'SizedString of at least 100 characters'", ->
	f = fn SizedString(10, undefined), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be
				'SizedString of at least 10 characters', got Boolean true.")

test "return an error with 'SizedString of at least 10 characters
			and of at most 100 characters'", ->
	f = fn SizedString(10, 100), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be 'SizedString of at least 10 characters
				and of at most 100 characters', got Boolean true.")

test "return an error with ''SizedString' arguments must be positive integers.'", ->
	expect(-> SizedString(-100, -10)).toThrow("'SizedString' arguments must be positive integers.")
	expect(-> SizedString(-100, 10)).toThrow("'SizedString' arguments must be positive integers.")
	expect(-> SizedString(undefined, -10)).toThrow("'SizedString' arguments must be positive integers.")
	expect(-> SizedString(-10, undefined)).toThrow("'SizedString' arguments must be positive integers.")

test "return an error with ''SizedString' max value cannot be less than min value", ->
	expect(-> SizedString(100, 10))
	.toThrow("'SizedString' max value cannot be less than min value.")
