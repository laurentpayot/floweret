import {fn, Any} from '../../dist'
import Type from '../../dist/types/Type'
import type from '../../dist/types/type'

describe "object", ->

	test "alias", ->
		f = fn type({a: Number}).as("Foo"), Any, ->
		expect(-> f(true))
		.toThrow("Expected argument #1 to be Foo: object type, got Boolean true.")

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

	test "no alias", ->
		warn = jest.spyOn(Type, 'warn')
		.mockImplementation(->) # silencing warn()
		f = fn type(Array(Number)), Any, ->
		expect(-> f(true))
		.toThrow("Expected argument #1 to be 'array of 'Number'', got Boolean true.")
		jest.restoreAllMocks()
		expect(warn).toHaveBeenCalledTimes(1)
		expect(warn).toHaveBeenCalledWith("Usage of 'type' is not needed without alias.")
