import {fn, Any, etc} from '../dist'
import promised from '../dist/types/promised'
import untyped from '../dist/types/untyped'
import TypedSet from '../dist/types/TypedSet'
import TypedMap from '../dist/types/TypedMap'

describe "Arguments of signature itself", ->

	test "not throw an error if no arguments types", ->
		f = fn Number, -> 1
		expect(f()).toBe(1)

	test "throw an error if signature result type is missing", ->
		expect(-> (fn -> 1))
		.toThrow("Result type is missing.")

	test "throw an error if signature function to wrap is missing", ->
		expect(-> (fn Number, Number))
		.toThrow("Function to wrap is missing.")

	test "throw an error if signature function to wrap is not an anonymous function", ->
		expect(-> (fn Number, Number, Number)).toThrow("Function to wrap is missing.")
		expect(-> (fn Number, Number, undefined)).toThrow("Function to wrap is missing.")
		expect(-> (fn Number, Number, null)).toThrow("Function to wrap is missing.")
		expect(-> (fn Number, Number, "foo")).toThrow("Function to wrap is missing.")
		expect(-> (fn Number, Number, Function)).toThrow("Function to wrap is missing.")
		expect(-> (fn Number, Number, foo = -> 1)).toThrow("Function to wrap is missing.")
		class Foo
		expect(-> (fn Number, Number, Foo)).toThrow("Function to wrap is missing.")

describe "Synchronous functions", ->

	test "do nothing if function returns a string", ->
		f = fn undefined, String,
			-> "foo"
		expect(f()).toBe("foo")

	test "throw an error if function returns a number", ->
		f = fn undefined, String,
			-> 1
		expect(-> f()).toThrow("Expected result to be String, got Number 1.")

	test "throw an error if function returns undefined", ->
		f = fn undefined, [String, Number],
			->
		expect(-> f()).toThrow("Expected result to be String or Number, got undefined.")

	test "do nothing if function returns undefined", ->
		f = fn undefined, undefined,
			->
		expect(f()).toBe(undefined)

describe "Asynchronous functions", ->

	test "return a promise if function returns promise", ->
		f = fn undefined, promised(Number),
			-> Promise.resolve(1)
		expect(f()?.constructor).toBe(Promise)

	test "do nothing if function returns a string promise", ->
		f = fn undefined, promised(String),
			-> Promise.resolve("foo")
		expect(f()).resolves.toBe("foo")

	test "throw an error if function returns a number promise", ->
		f = fn undefined, promised(String),
			-> Promise.resolve(1)
		expect(f()).rejects.toThrow("Expected promise result to be String, got Number 1.")

	test "throw an error if function does not return a promise", ->
		f = fn undefined, promised(String),
			-> '1'
		expect(f()).rejects.toThrow("Expected result to be a promise of type String, got String \"1\".")

	test "throw an error if promised used without type", ->
		expect(-> fn undefined, promised(),
			-> Promise.resolve(1)
		).toThrow("'promised' must have exactly 1 argument.")

	test "throw an error if promised used as a function", ->
		f = fn undefined, promised,
			-> Promise.resolve(1)
		expect(-> f()).toThrow("'promised' must have exactly 1 argument.")

describe "Arguments number", ->

	test "do nothing if function has the right number of arguments", ->
		f = fn Number, [Number, String], Any,
			(n1, n2=0) -> n1 + n2
		expect(f(1, 2)).toBe(3)

	test "raise an error if function that takes no argument has an argument", ->
		f = fn Any,
			-> 1
		expect(-> f(1)).toThrow("Too many arguments provided.")

	test "raise an error if function has too many arguments", ->
		f = fn Number, [Number, String], Any,
			(n1, n2=0) -> n1 + n2
		expect(-> f(1, 2, 3)).toThrow("Too many arguments provided.")

	test "raise an error if function has too few arguments", ->
		f = fn Number, [Number, String], Any,
			(n1, n2=0) -> n1 + n2
		expect(-> f(1)).toThrow("Expected argument #2 to be Number or String, got undefined.")

	test "do nothing if all unfilled arguments are optional", ->
		f = fn Number, [Number, String, undefined], Any,
			(n1, n2=0) -> n1 + n2
		expect(f(1)).toBe(1)
		expect(f(1, undefined)).toBe(1)
		f = fn Number, [Number, String, undefined], Number, Any,
			(n1, n2=0, n3) -> n1 + n2 + n3
		expect(f(1, undefined, 3)).toBe(4)

	test "do nothing if all unfilled arguments type is any type", ->
		f = fn Number, Any, Any,
			(n1, n2=0) -> n1 + n2
		expect(f(1)).toBe(1)
		expect(f(1, undefined)).toBe(1)
		f = fn Number, Any, Number, Any,
			(n1, n2=0, n3) -> n1 + n2 + n3
		expect(f(1, undefined, 3)).toBe(4)

	test "raise an error if some unfilled arguments are not optional", ->
		f = fn Number, [Number, String, undefined], Number, Any,
			(n1, n2=0, n3) -> n1 + n2 + n3
		expect(-> f(1)).toThrow("Expected argument #3 to be Number, got undefined.")
		expect(-> f(1, 2)).toThrow("Expected argument #3 to be Number, got undefined.")

	test "raise an error when an optional argument is filled with null", ->
		f = fn Number, [Number, undefined], Any,
			(n1, n2=0) -> n1 + n2
		expect(-> f(1, null))
		.toThrow("Expected argument #2 to be Number or undefined, got null.")

	test "raise an error when only an optional argument and value is null", ->
		f = fn undefined, Any,
			(n1=0) -> n1
		expect(-> f(null)).toThrow("Expected argument #1 to be undefined, got null.")

	test "raise an error when only an optional argument and value isnt undefined", ->
		f = fn undefined, Any,
			(n1=0) -> n1
		expect(-> f(1)).toThrow("Expected argument #1 to be undefined, got Number 1.")

	test "do nothing if only an optional argument and value is undefined", ->
		f = fn undefined, Any,
			(n1=0) -> n1
		expect(f(undefined)).toBe(0)

	test "do nothing if only an optional argument and value is not filled", ->
		f = fn undefined, Any,
			(n1=0) -> n1
		expect(f()).toBe(0)

describe "Rest type", ->

	test "return the concatenation of zero argument of String type", ->
		f = fn etc(String), String,
			(str...) -> str.join('')
		expect(f()).toBe('')
		f = fn Number, etc(String), String,
			(n, str...) -> n + str.join('')
		expect(f(1)).toBe('1')

	test "return the concatenation of one argument of String type", ->
		f = fn etc(String), String,
			(str...) -> str.join('')
		expect(f('abc')).toBe('abc')
		f = fn Number, etc(String), String,
			(n, str...) -> n + str.join('')
		expect(f(1, 'abc')).toBe('1abc')

	test "return the concatenation of all the arguments of String type", ->
		f = fn etc(String), String,
			(str...) -> str.join('')
		expect(f('a', 'bc', 'def')).toBe('abcdef')
		f = fn Number, etc(String), String,
			(n, str...) -> n + str.join('')
		expect(f(1, 'a', 'bc', 'def')).toBe('1abcdef')

	test "throw an error if an argument is not a string", ->
		f = fn etc(String), String,
			(str...) -> str.join('')
		expect(-> f('a', 5, 'def'))
		.toThrow("Expected argument #2 to be String, got Number 5.")
		f = fn Number, etc(String), String,
			(n, str...) -> n + str.join('')
		expect(-> f(1, 'a', 5, 'def'))
		.toThrow("Expected argument #3 to be String, got Number 5.")

	test "throw an error if an argument is not a number", ->
		f = fn etc(Number), String,
			(str...) -> str.join('')
		expect(-> f('a', 5, 'def'))
		.toThrow("Expected argument #1 to be Number, got String \"a\".")
		f = fn Number, etc(Number), String,
			(n, str...) -> n + str.join('')
		expect(-> f(1, 'a', 5, 'def'))
		.toThrow("Expected argument #2 to be Number, got String \"a\".")

	test "return the concatenation of all the arguments of String or Number type", ->
		f = fn etc([String, Number]), String,
			(str...) -> str.join('')
		expect(f('a', 1, 'def')).toBe('a1def')
		f = fn Number, etc([String, Number]), String,
			(n, str...) -> n + str.join('')
		expect(f(1, 'a', 2, 'def')).toBe('1a2def')

	test "throw an error if an argument is not a string or a Number type", ->
		f = fn etc([String, Number]), String,
			(str...) -> str.join('')
		expect(-> f('a', true, 'def'))
		.toThrow("Expected argument #2 to be String or Number, got Boolean true.")
		f = fn Number, etc([String, Number]), String,
			(n, str...) -> n + str.join('')
		expect(-> f(1, 'a', true, 'def'))
		.toThrow("Expected argument #3 to be String or Number, got Boolean true.")

	# ### CoffeeScript only ###
	# test "NOT throw an error if splat is not the last of the argument types", ->
	# 	f = fn [Number, etc(String)], String,
	# 		(n, str...) -> n + str.join('')
	# 	expect(f(1, 'a', 'b', 'c')).toBe("abc1")
	# 	f = fn [etc(String), Number], String,
	# 		(str..., n) -> str.join('') + n
	# 	expect(f('a', 'b', 'c', 1)).toBe("abc1")
	# 	f = fn [Number, etc(String), Number], String,
	# 		(n1, str..., n2) -> n1 + str.join('') + n2
	# 	expect(f(1, 'a', 'b', 'c', 2)).toBe("1abc2")

	test "throw an error if rest type is not the last of the argument types", ->
		f = fn etc(String), String, String,
			(str...) -> str.join('')
		expect(-> f('a', 'bc', 'def'))
		.toThrow("Rest type must be the last of the arguments types.")
		f = fn Number, etc(String), String, String,
			(n, str...) -> n + str.join('')
		expect(-> f(1, 'a', 'bc', 'def'))
		.toThrow("Rest type must be the last of the arguments types.")

	test "return the concatenation of all the arguments of any type", ->
		f = fn etc(Any), String,
			(str...) -> str.join('')
		expect(f('a', 5, 'def')).toBe('a5def')
		f = fn Number, etc(Any), String,
			(n, str...) -> n + str.join('')
		expect(f(1, 'a', 5, 'def')).toBe('1a5def')

	test "behave like etc(Any) when type is ommited", ->
		f = fn etc(), String,
			(str...) -> str.join('')
		expect(f('a', 5, 'def')).toBe('a5def')
		f = fn Number, etc(), String,
			(n, str...) -> n + str.join('')
		expect(f(1, 'a', 5, 'def')).toBe('1a5def')

	test "behave like etc(Any) when used as a function", ->
		f = fn etc, String,
			(str...) -> str.join('')
		expect(f('a', 5, 'def')).toBe('a5def')
		f = fn Number, etc, String,
			(n, str...) -> n + str.join('')
		expect(f(1, 'a', 5, 'def')).toBe('1a5def')

describe "Auto-typing", ->

	describe "object type", ->

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

	describe "TypedSet", ->

		test "input parameter side effects", ->
			f = fn Boolean, TypedSet(Number), Any, Any,
				(foo, bar, baz) -> bar.add(baz)
			s = new Set([1, 2, 3])
			expect([f(true, s, 4)...]).toEqual([1, 2, 3, 4])
			expect([s...]).toEqual([1, 2, 3, 4])

		test "input parameter no side effects when invalid", ->
			f = fn Boolean, TypedSet(Number), Any, Any,
				(foo, bar, baz) -> bar.add(baz)
			s = new Set([1, 2, 3])
			expect(-> f(true, s, true))
			.toThrow("Expected set element to be Number, got Boolean true.")
			expect([s...]).toEqual([1, 2, 3])

		test "input parameter was not proxyfied", ->
			f = fn Boolean, TypedSet(Number), Any, Any,
				(foo, bar, baz) -> bar.add(baz)
			s = new Set([1, 2, 3])
			expect([f(true, s, 4)...]).toEqual([1, 2, 3, 4])
			expect([s...]).toEqual([1, 2, 3, 4])
			expect(-> s.add(false)).not.toThrow()
			expect([s...]).toEqual([1, 2, 3, 4, false])

		# TODO: more tests!!!

	describe "TypedMap", ->

		test "input parameter side effects", ->
			f = fn Boolean, TypedMap(Number, String), Any, Any, Any,
				(foo, bar, k, v) -> bar.set(k, v)
			m = new Map([[1,'1'], [2,'2'], [3,'3']])
			expect([f(true, m, 4, '4')...]).toEqual([[1,'1'], [2,'2'], [3,'3'], [4,'4']])
			expect([m...]).toEqual([[1,'1'], [2,'2'], [3,'3'], [4,'4']])

		test "input parameter no side effects when invalid", ->
			f = fn Boolean, TypedMap(Number, String), Any, Any, Any,
				(foo, bar, k, v) -> bar.set(k, v)
			m = new Map([[1,'1'], [2,'2'], [3,'3']])
			expect(-> f(true, m, 4, true))
			.toThrow("Expected map element value to be String, got Boolean true.")
			expect([m...]).toEqual([[1,'1'], [2,'2'], [3,'3']])

		test "input parameter was not proxyfied", ->
			f = fn Boolean, TypedMap(Number, String), Any, Any, Any,
				(foo, bar, k, v) -> bar.set(k, v)
			m = new Map([[1,'1'], [2,'2'], [3,'3']])
			expect([f(true, m, 4, '4')...]).toEqual([[1,'1'], [2,'2'], [3,'3'], [4,'4']])
			expect([m...]).toEqual([[1,'1'], [2,'2'], [3,'3'], [4,'4']])
			expect(-> m.set(true, false)).not.toThrow()
			expect([m...]).toEqual([[1,'1'], [2,'2'], [3,'3'], [4,'4'], [true,false]])

		# TODO: more tests!!!

	describe "untyped", ->

		test "untyped object parameter", ->
			f = fn Boolean, untyped({a: Number, b: Number}), Any, Any,
				(foo, bar, baz) -> bar.b = baz
			o = {a: 1, b: 2}
			expect(f(true, o, 3)).toEqual(3)
			expect(o).toEqual({a: 1, b: 3}) # side effects for input parameter
			o.a = false
			expect(o).toEqual({a: false, b: 3}) # input object was not proxyfied
			expect(f(true, {a: 1, b: 2}, true)).toEqual(true) # parameter was not internally proxyfied

		test "untyped result", ->
			f = fn undefined, untyped({a: Number, b: Number}),
				-> {a: 1, b: 2}
			result = f()
			expect(result).toEqual({a: 1, b: 2})
			expect(-> result.b = true).not.toThrow()
			expect(result).toEqual({a: 1, b: true})
