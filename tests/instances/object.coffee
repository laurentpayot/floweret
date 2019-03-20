import {object} from '../../src'

test "init", ->
	o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
	expect(o).toEqual({a: 1, b: {c: 2}})

test "shallow set", ->
	o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
	o.a = 3
	expect(o).toEqual({a: 3, b: {c: 2}})

test "deep set", ->
	o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
	o.b.c = 3
	expect(o).toEqual({a: 1, b: {c: 3}})

test "trow an error with a non-object type", ->
	expect(-> o = object Number, {a: 1, b: {c: 2}})
	.toThrow("'object' argument #1 must be an Object type.")

test "trow an error with a non-object object", ->
	expect(-> o = object {a: Number, b: {c: Number}}, "foo")
	.toThrow("'object' argument #2 should be of type 'object type' instead of String \"foo\"")

test "trow an error for a shallow type mismatch and leave object unmodified", ->
	o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
	expect(-> o.a = true)
	.toThrow("Object instance should be an object with key 'a' of type 'Number' instead of Boolean true.")
	expect(o).toEqual({a: 1, b: {c: 2}})

test "trow an error for a deep type mismatch and leave object unmodified", ->
	o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
	expect(-> o.b.c = true)
	.toThrow("Object instance should be an object with key 'b.c' of type 'Number' instead of Boolean true.")
	expect(o).toEqual({a: 1, b: {c: 2}})

test "trow an error for a deep-deep type mismatch and leave object unmodified", ->
	o = object {a: Number, b: {c: {d: Number}, e: Number}}, {a: 1, b: {c: {d: 2}, e: 3}}
	expect(-> o.b.c.d = true)
	.toThrow("Object instance should be an object with key 'b.c.d' of type 'Number' instead of Boolean true.")
	expect(o).toEqual({a: 1, b: {c: {d: 2}, e: 3}})

