import {check, fn, Any, etc} from '../../dist'
import TypedObject from '../../dist/types/TypedObject'

test "init", ->
	o = check TypedObject(Number), {a: 1, b: 2}
	expect(o).toEqual({a: 1, b: 2})

test "init empty object", ->
	expect(-> o = check TypedObject(Number), {}).not.toThrow()

test "set new prop", ->
	o = check TypedObject(Number), {a: 1, b: 2}
	o.c = 3
	expect(o).toEqual({a: 1, b: 2, c: 3})

test "set existing prop", ->
	o = check TypedObject(Number), {a: 1, b: 2}
	o.b = 3
	expect(o).toEqual({a: 1, b: 3})

test "trow an error with a non-object value", ->
	expect(-> o = check TypedObject(Number), true)
	.toThrow("Expected object with values of type 'Number', got Boolean true.")

test "trow an error with an invalid object", ->
	expect(-> o = check TypedObject(Number), {a: 1, b: true})
	.toThrow("Expected object property 'b' to be Number, got Boolean true.")

test "trow an error for a shallow type mismatch and leave object unmodified", ->
	o = check TypedObject(Number), {a: 1, b: 2}
	expect(-> o.a = true)
	.toThrow("Expected object property 'a' to be Number, got Boolean true.")
	expect(o).toEqual({a: 1, b: 2})

test "trow an error for a deep type mismatch and leave object unmodified", ->
	o = check TypedObject(Number), {a: 1, b: 2}
	expect(-> o.b = {c: true})
	.toThrow("Expected object property 'b' to be Number, got Object.")
	expect(o).toEqual({a: 1, b: 2})

test "do not trow an error for a deletion", ->
	o = check TypedObject(Number), {a: 1, b: 2}
	expect(-> delete o.b).not.toThrow()
	expect(o).toEqual({a: 1})
	expect(-> delete o.a).not.toThrow()
	expect(o).toEqual({})

describe "fn auto-typing", ->

	test "parameter typed as TypedObject", ->
		f = fn Boolean, TypedObject(Number), Any, Any,
			(foo, bar, baz) -> bar.b = baz
		o = {a: 1, b: 2}
		expect(f(true, o, 3)).toEqual(3)
		expect(o).toEqual({a: 1, b: 3}) # side effects for input parameter
		expect(-> o.a = false).not.toThrow()
		expect(o).toEqual({a: false, b: 3}) # input parameter was not proxyfied
		expect(-> f(true, {a: 1, b: 2}, true))
		.toThrow("Expected argument #2 object property 'b' to be Number, got Boolean true.")

	test "result typed as TypedObject", ->
		f = fn undefined, TypedObject(Number),
			-> {a: 1, b: 2}
		result = f()
		expect(result).toEqual({a: 1, b: 2})
		expect(-> result.b = true)
		.toThrow("Expected result object property 'b' to be Number, got Boolean true.")
		expect(result).toEqual({a: 1, b: 2})

	test "result typed promised object", ->
		f = fn undefined, Promise.resolve(TypedObject(Number)),
			-> Promise.resolve({a: 1, b: 2})
		result = await f()
		expect(result).toEqual({a: 1, b: 2})
		expect(-> result.b = true)
		.toThrow("Expected promise result object property 'b' to be Number, got Boolean true.")
		expect(result).toEqual({a: 1, b: 2})

	test "rest parameter typed as TypedObject", ->
		f = fn Any, etc(TypedObject(Number)), Any,
			(foo, bar...) -> bar[0].b = foo
		o = {a: 1, b: 2}
		expect(f(3, o)).toEqual(3)
		expect(o).toEqual({a: 1, b: 3}) # side effects for input parameter
		expect(-> o.a = false).not.toThrow()
		expect(o).toEqual({a: false, b: 3}) # input parameter was not proxyfied
		expect(-> f(true, {a: 1, b: 2}))
		.toThrow("Expected argument #2 object property 'b' to be Number, got Boolean true.")
