import {fn, Any} from '../../dist'
import Tuple from '../../dist/types/Tuple'
import type from '../../dist/types/type'
import Type from '../../dist/types/Type'

test "return an error with 'tuple of 3 elements 'Number, Boolean, String''", ->
	f = fn Tuple(Number, Boolean, String), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be
			tuple of 3 elements 'Number, Boolean, String', got Number 1.")

test "return an error with 'tuple of 3 elements 'Number, Object or null, String''", ->
	f = fn Tuple(Number, [Object, null], String), Any, ->
	expect(-> f(1))
	.toThrow("Expected argument #1 to be
			tuple of 3 elements 'Number, Object or null, String', got Number 1.")

test "return an error with 'tuple of 3 elements 'Number, Boolean, String''", ->
	f = fn Tuple(Number, Boolean, String), Any, ->
	expect(-> f(Tuple(1, 2, "three")))
	.toThrow("Expected argument #1 to be tuple of 3 elements 'Number, Boolean, String', got Tuple.")

test "alias", ->
	f = fn Tuple(Number, Boolean, String).as("Trio"), Any, ->
	expect(-> f([1, 2, "three"]))
	.toThrow("Expected argument #1 Trio tuple element 1 to be Boolean, got Number 2.")

test "type() with alias", ->
	warn = jest.spyOn(Type, 'warn')
	.mockImplementation(->) # silencing warn()
	f = fn type(Tuple(Number, Number)).as("Duo"), Any, ->
	jest.restoreAllMocks()
	expect(warn).toHaveBeenCalledTimes(1)
	expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed with type Tuple.")
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Duo: tuple of 2 elements 'Number, Number', got Boolean true.")

test "type() without alias", ->
	warn = jest.spyOn(Type, 'warn')
	.mockImplementation(->) # silencing warn()
	f = fn type(Tuple(Number, Number)), Any, ->
	expect(warn).toHaveBeenCalledTimes(1)
	expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed with type Tuple.")
	expect(-> f(true))
	.toThrow("Expected argument #1 to be tuple of 2 elements 'Number, Number', got Boolean true.")
	jest.restoreAllMocks()
	expect(warn).toHaveBeenCalledTimes(2)
	expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed without alias.")
