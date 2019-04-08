import {typed, fn, Any, etc} from '../../dist'

test "init", ->
	Obj = {a: Number, b: {c: Number}}
	o = typed Obj, {a: 1, b: {c: 2}}
	expect(o).toEqual({a: 1, b: {c: 2}})

test "init empty object", ->
	Obj = {a: Number, b: {c: Number}}
	expect(-> o = typed Obj, {})
	.toThrow("Expected an object with key 'a' of type 'Number' instead of missing key 'a'.")

test "shallow set", ->
	Obj = {a: Number, b: {c: Number}}
	o = typed Obj, {a: 1, b: {c: 2}}
	o.a = 3
	expect(o).toEqual({a: 3, b: {c: 2}})

test "deep set", ->
	Obj = {a: Number, b: {c: Number}}
	o = typed Obj, {a: 1, b: {c: 2}}
	o.b.c = 3
	expect(o).toEqual({a: 1, b: {c: 3}})

test "trow an error with a non-object type", ->
	expect(-> o = typed Number, {a: 1, b: {c: 2}})
	.toThrow("Expected Number, got Object.")

test "trow an error with a non-object object", ->
	Obj = {a: Number, b: {c: Number}}
	expect(-> o = typed Obj, "foo")
	.toThrow("Expected object type, got String \"foo\"")

test "trow an error for a shallow type mismatch and leave object unmodified", ->
	Obj = {a: Number, b: {c: Number}}
	o = typed Obj, {a: 1, b: {c: 2}}
	expect(-> o.a = true)
	.toThrow("Expected an object with key 'a' of type 'Number' instead of Boolean true.")
	expect(o).toEqual({a: 1, b: {c: 2}})

test "trow an error for a deep type mismatch and leave object unmodified", ->
	Obj = {a: Number, b: {c: Number}}
	o = typed Obj, {a: 1, b: {c: 2}}
	expect(-> o.b.c = true)
	.toThrow("Expected an object with key 'b.c' of type 'Number' instead of Boolean true.")
	expect(o).toEqual({a: 1, b: {c: 2}})

test "trow an error for a deep-deep type mismatch and leave object unmodified", ->
	Obj = {a: Number, b: {c: {d: Number}, e: Number}}
	o = typed Obj, {a: 1, b: {c: {d: 2}, e: 3}}
	expect(-> o.b.c.d = true)
	.toThrow("Expected an object with key 'b.c.d' of type 'Number' instead of Boolean true.")
	expect(o).toEqual({a: 1, b: {c: {d: 2}, e: 3}})

describe "fn auto-typing", ->

	test "parameter typed as object", ->
		f = fn Boolean, {a: Number, b: Number}, Any, Any,
			(foo, bar, baz) -> bar.b = baz
		o = {a: 1, b: 2}
		expect(f(true, o, 3)).toEqual(3)
		expect(o).toEqual({a: 1, b: 3}) # side effects for input parameter
		expect(-> o.a = false).not.toThrow()
		expect(o).toEqual({a: false, b: 3}) # input parameter was not proxyfied
		expect(-> f(true, {a: 1, b: 2}, true))
		.toThrow("Expected an object with key 'b' of type 'Number' instead of Boolean true.")

	test "result typed as object", ->
		f = fn undefined, {a: Number, b: Number},
			-> {a: 1, b: 2}
		result = f()
		expect(result).toEqual({a: 1, b: 2})
		expect(-> result.b = true)
		.toThrow("Expected an object with key 'b' of type 'Number' instead of Boolean true.")
		expect(result).toEqual({a: 1, b: 2})

	test "result typed promised object", ->
		f = fn undefined, Promise.resolve({a: Number, b: Number}),
			-> Promise.resolve({a: 1, b: 2})
		result = await f()
		expect(result).toEqual({a: 1, b: 2})
		expect(-> result.b = true)
		.toThrow("Expected an object with key 'b' of type 'Number' instead of Boolean true.")
		expect(result).toEqual({a: 1, b: 2})

	test "rest parameter typed as object", ->
		f = fn Any, etc({a: Number, b: Number}), Any,
			(foo, bar...) -> bar[0].b = foo
		o = {a: 1, b: 2}
		expect(f(3, o)).toEqual(3)
		expect(o).toEqual({a: 1, b: 3}) # side effects for input parameter
		expect(-> o.a = false).not.toThrow()
		expect(o).toEqual({a: false, b: 3}) # input parameter was not proxyfied
		expect(-> f(true, {a: 1, b: 2}))
		.toThrow("Expected an object with key 'b' of type 'Number' instead of Boolean true.")
