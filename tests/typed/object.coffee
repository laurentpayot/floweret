import {typed} from '../../dist'

test "init", ->
	Obj = {a: Number, b: {c: Number}}
	o = typed Obj, {a: 1, b: {c: 2}}
	expect(o).toEqual({a: 1, b: {c: 2}})

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
	.toThrow("Expected 'Number', got Object.")

test "trow an error with a non-object object", ->
	Obj = {a: Number, b: {c: Number}}
	expect(-> o = typed Obj, "foo")
	.toThrow("Expected 'object type', got String \"foo\"")

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

