import {fn, Any, etc} from '../dist'
import promised from '../dist/types/promised'

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
		expect(-> f()).toThrow("Result should be of type 'String' instead of Number 1.")

	test "throw an error if function returns undefined", ->
		f = fn undefined, [String, Number],
			->
		expect(-> f()).toThrow("Result should be of type 'String or Number' instead of undefined.")

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
		expect(f()).rejects.toThrow("Promise result should be of type 'String' instead of Number 1.")

	test "throw an error if function does not return a promise", ->
		f = fn undefined, promised(String),
			-> '1'
		expect(f()).rejects.toThrow("Result should be a promise of type 'String' instead of String \"1\".")

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
		expect(-> f(1)).toThrow("Missing required argument number 2.")

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
		expect(-> f(1)).toThrow("Missing required argument number 3.")
		expect(-> f(1, 2)).toThrow("Missing required argument number 3.")

	test "raise an error when an optional argument is filled with null", ->
		f = fn Number, [Number, undefined], Any,
			(n1, n2=0) -> n1 + n2
		expect(-> f(1, null))
		.toThrow("Argument #2 should be of type 'Number or undefined' instead of null.")

	test "raise an error when only an optional argument and value is null", ->
		f = fn undefined, Any,
			(n1=0) -> n1
		expect(-> f(null)).toThrow("Argument #1 should be of type 'undefined' instead of null.")

	test "raise an error when only an optional argument and value isnt undefined", ->
		f = fn undefined, Any,
			(n1=0) -> n1
		expect(-> f(1)).toThrow("Argument #1 should be of type 'undefined' instead of Number 1.")

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
		.toThrow("Argument #2 should be of type 'String' instead of Number 5.")
		f = fn Number, etc(String), String,
			(n, str...) -> n + str.join('')
		expect(-> f(1, 'a', 5, 'def'))
		.toThrow("Argument #3 should be of type 'String' instead of Number 5.")

	test "throw an error if an argument is not a number", ->
		f = fn etc(Number), String,
			(str...) -> str.join('')
		expect(-> f('a', 5, 'def'))
		.toThrow("Argument #1 should be of type 'Number' instead of String \"a\".")
		f = fn Number, etc(Number), String,
			(n, str...) -> n + str.join('')
		expect(-> f(1, 'a', 5, 'def'))
		.toThrow("Argument #2 should be of type 'Number' instead of String \"a\".")

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
		.toThrow("Argument #2 should be of type 'String or Number' instead of Boolean true.")
		f = fn Number, etc([String, Number]), String,
			(n, str...) -> n + str.join('')
		expect(-> f(1, 'a', true, 'def'))
		.toThrow("Argument #3 should be of type 'String or Number' instead of Boolean true.")

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
