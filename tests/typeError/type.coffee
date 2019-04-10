import {fn, Any} from '../../dist'
import Type from '../../dist/types/Type'
import type from '../../dist/types/type'
import Tuple from '../../dist/types/Tuple'


test "object aliased type", ->
	f = fn type({a: Number}).as("Foo"), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Foo, got Boolean true.")

test "object aliased type without alias", ->
	f = fn type({a: Number}), Any, ->
	expect(-> f(true))
	.toThrow("Expected argument #1 to be object type, got Boolean true.")

test "object aliased type on Tuple with alias", ->
	warn = jest.spyOn(Type, 'warn')
	.mockImplementation(->) # silencing warn()
	f = fn type(Tuple(Number, Number)).as("Duo"), Any, ->
	jest.restoreAllMocks()
	expect(warn).toHaveBeenCalledTimes(1)
	expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed with type Tuple.")
	expect(-> f(true))
	.toThrow("Expected argument #1 to be Duo, got Boolean true.")

test "object aliased type on Tuple without alias", ->
	warn = jest.spyOn(Type, 'warn')
	.mockImplementation(->) # silencing warn()
	f = fn type(Tuple(Number, Number)), Any, ->
	jest.restoreAllMocks()
	expect(warn).toHaveBeenCalledTimes(1)
	expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed with type Tuple.")
	expect(-> f(true))
	.toThrow("Expected argument #1 to be tuple of 2 elements 'Number, Number', got Boolean true.")
