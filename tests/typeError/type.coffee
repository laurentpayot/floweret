import {fn, Any} from '../../dist'
import Type from '../../dist/types/Type'
import type from '../../dist/types/type'
import Tuple from '../../dist/types/Tuple'

describe "object", ->

	test "alias", ->
		f = fn type({a: Number}).as("Foo"), Any, ->
		expect(-> f(true))
		.toThrow("Expected argument #1 to be Foo: object type, got Boolean true.")
		expect(-> f({a: 'foo'}))
		.toThrow("Expected argument #1 to be Foo: an object with key 'a' of type 'Number' instead of String \"foo\".")

	test "no alias", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		f = fn type({a: Number}), Any, ->
		expect(-> f(true))
		.toThrow("Expected argument #1 to be object type, got Boolean true.")
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed without alias.")

describe "array", ->

	test "alias", ->
		f = fn type(Array(Number)).as("Foo"), Any, ->
		expect(-> f(true))
		.toThrow("Expected argument #1 to be Foo: 'array of 'Number'', got Boolean true.")
		expect(-> f([1, true, 3]))
		.toThrow("Expected argument #1 to be Foo: an array with element 1 of type 'Number' instead of Boolean true.")

	test "no alias", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		f = fn type(Array(Number)), Any, ->
		expect(-> f(true))
		.toThrow("Expected argument #1 to be 'array of 'Number'', got Boolean true.")
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed without alias.")

describe "sized array", ->

	test "alias", ->
		f = fn type(Array(3)).as("Foo"), Any, ->
		expect(-> f(true))
		.toThrow("Expected argument #1 to be Foo: 'array of 3 elements', got Boolean true.")
		expect(-> f([1, true, 'tree', NaN]))
		.toThrow("Expected argument #1 to be Foo: an array with a length of 3 instead of 4.")

	test "no alias", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		f = fn type(Array(3)), Any, ->
		expect(-> f(true))
		.toThrow("Expected argument #1 to be 'array of 3 elements', got Boolean true.")
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed without alias.")

describe "custom type (Tuple)", ->

	test "alias", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		f = fn type(Tuple(Number, Number)).as("Duo"), Any, ->
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed with type Tuple.")
		expect(-> f(true))
		.toThrow("Expected argument #1 to be Duo: tuple of 2 elements 'Number, Number', got Boolean true.")

	test "no alias", ->
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
