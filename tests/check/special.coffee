import {check, Any, maybe, etc} from '../../dist'
import Type from '../../dist/types/Type'
import promised from '../../dist/types/promised'
import constraint from '../../dist/types/constraint'


test "empty array", ->
	a = check [], []
	expect(a).toEqual([])
	expect(-> a.push(1))
	.toThrow("Expected an empty array, got a non-empty array.")

test "empty object", ->
	o = check {}, {}
	expect(o).toEqual({})
	expect(-> o.a = 1)
	.toThrow("Expected an object with key 'a' of type 'undefined' instead of Number 1.")


test "Any as function", ->
	warn = jest.spyOn(Type, 'warn')
	.mockImplementation(->) # silencing warn()
	expect(check Any, 1).toBe(1)
	jest.restoreAllMocks()
	expect(warn).toHaveBeenCalledTimes(1)
	expect(warn).toHaveBeenCalledWith("Any is not needed as 'check' argument.")

test "Any() ast type instance ", ->
	warn = jest.spyOn(Type, 'warn')
	.mockImplementation(->) # silencing warn()
	expect(check Any(), 1).toBe(1)
	jest.restoreAllMocks()
	expect(warn).toHaveBeenCalledTimes(1)
	expect(warn).toHaveBeenCalledWith("Any is not needed as 'check' argument.")

test "maybe init", ->
	expect(check maybe([Number, String]), 1).toBe(1)
	expect(check maybe([Number, String]), '1').toBe('1')
	expect(check maybe([Number, String]), undefined).toBe(undefined)
	expect(-> check maybe([Number, String]), false)
	.toThrow("Expected undefined or Number or String, got Boolean false.")

test "maybe after init", ->
	n = check maybe(Array(Number)), [1, 2, 3]
	expect(n).toEqual([1, 2, 3])
	expect(-> n.push(true))
	.toThrow("Expected an array with element 3 of type 'Number' instead of Boolean true.")

test "throw an error when checking for an instance of Type", ->
	expect(-> check Type, Any())
	.toThrow("Expected Type, got Any.")

test "throw an error for a promised number.", ->
	expect(-> check Promise.resolve(Number), Promise.resolve(1))
	.toThrow("Type can not be an instance of Promise. Use Promise as type instead.")
	expect(-> check promised(Number), Promise.resolve(1))
	.toThrow("Type can not be an instance of Promise. Use Promise as type instead.")

test "return true when type is MyClass, false for other types", ->
	class MyClass
	mc = new MyClass
	expect(check MyClass, mc).toEqual(mc)
	expect(-> check MyClass, 1)
	.toThrow("Expected MyClass, got Number 1.")

test "throw an error with 'etc'", ->
	expect(-> check etc(Number), 1)
	.toThrow("'etc' cannot be used in types.")
	expect(-> check etc(), 1)
	.toThrow("'etc' cannot be used in types.")
	expect(-> check etc, 1)
	.toThrow("'etc' cannot be used in types.")

test "other type (Symbol)", ->
	f = Symbol("foo")
	expect(check Symbol, f).toEqual(f)
