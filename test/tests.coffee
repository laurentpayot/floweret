{typeOf, isType, sig, maybe, promised, etc} = require '../index.js' # testing the build, not the source

chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use(chaiAsPromised)
expect = chai.expect

NATIVE_TYPES = [undefined, null, Boolean, Number, String, Array, Date, Object,
				Function, Promise, Int8Array, Set, Map, Symbol]
VALUES = [
	undefined
	null
	1.1 # number
	0 # number
	true # boolean
	false # boolean
	"" # string
	"a" # string
	" " # string
	"Énorme !" # string
	[] #array
	[1, 'a', null, undefined] #array
	new Int8Array([1, 2]) # typed array
	{} # object
	{foo: 'bar'} # object
	{name: 'Number'} # tricky object
	{a: 1, b: {a: 2, b: null, c: '3'}} # object
	new Date()
	(->) # function
	new Promise(->) # promise
	new Set([]) # set
	new Set([1, 2])
	new Map([]) # map
	new Map([[ 1, 'one' ],[ 2, 'two' ]])
	Symbol('foo') # symbol
]

testTypes = (val, type) ->
	expect(isType(val, type)).to.be.true
	expect(isType(val, t)).to.be.false for t in NATIVE_TYPES when t isnt type



###
	████████╗██╗   ██╗██████╗ ███████╗ ██████╗ ███████╗
	╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔═══██╗██╔════╝
	   ██║    ╚████╔╝ ██████╔╝█████╗  ██║   ██║█████╗
	   ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ██║   ██║██╔══╝
	   ██║      ██║   ██║     ███████╗╚██████╔╝██║
	   ╚═╝      ╚═╝   ╚═╝     ╚══════╝ ╚═════╝ ╚═╝
###
describe "typeOf (add more tests!!!!!!!!!!!!!!!!!!!!)", ->

	it "should return 'Object' for an object value, something else otherwise", ->
		expect(typeOf({})).to.equal('Object')
		expect(typeOf({a: 1})).to.equal('Object')
		expect(typeOf({a: 1, b: {c: 1}})).to.equal('Object')
		expect(typeOf(null)).to.not.equal('Object')
		expect(typeOf(undefined)).to.not.equal('Object')
		expect(typeOf([])).to.not.equal('Object')
		expect(typeOf([1])).to.not.equal('Object')
		expect(typeOf(Object)).to.not.equal('Object')
		expect(typeOf(-> {})).to.not.equal('Object')

	it "should return 'Object' for an object value even after Object.name modification", ->
		Object.name = "foo"
		expect(typeOf({})).to.equal('Object')

	it "should return 'Function' for a function value, something else otherwise", ->
		expect(typeOf(->)).to.equal('Function')
		expect(typeOf(-> 1)).to.equal('Function')
		expect(typeOf(Function)).to.equal('Function')
		expect(typeOf(String)).to.equal('Function')
		expect(typeOf(Number)).to.equal('Function')
		expect(typeOf(Array)).to.equal('Function')
		expect(typeOf(Object)).to.equal('Function')
		expect(typeOf(null)).to.not.equal('Function')
		expect(typeOf(undefined)).to.not.equal('Function')

	it "should return 'Function' for an Function value even after Function.name modification", ->
		Function.name = "foo"
		expect(typeOf(->)).to.equal('Function')

###
	██╗███████╗████████╗██╗   ██╗██████╗ ███████╗
	██║██╔════╝╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
	██║███████╗   ██║    ╚████╔╝ ██████╔╝█████╗
	██║╚════██║   ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
	██║███████║   ██║      ██║   ██║     ███████╗
	╚═╝╚══════╝   ╚═╝      ╚═╝   ╚═╝     ╚══════╝
###
describe "isType", ->

	context "Special Types", ->

		context "Maybe type", ->

			it "should return true when value is undefined or null.", ->
				for t in NATIVE_TYPES
					expect(isType(undefined, maybe(t))).to.be.true
					expect(isType(null, maybe(t))).to.be.true

			it "should return true for a number type, false for other types.", ->
				expect(isType(1.1, maybe(Number))).to.be.true
				expect(isType(1.1, maybe(t))).to.be.false for t in NATIVE_TYPES when t and t isnt Number

			it "should return true for a string type, false for other types.", ->
				expect(isType("Énorme !", maybe(String))).to.be.true
				expect(isType("Énorme !", maybe(t))).to.be.false for t in NATIVE_TYPES when t and t isnt String


		context "Any type ([])", ->

			it "should return true for all values", ->
				expect(isType(val, [])).to.be.true for val in VALUES


	context "Literal Types", ->

		it "should return true when value is the same string as the type literal, false if different", ->
			expect(isType("foo", "foo")).to.be.true
			expect(isType("Énorme !", "Énorme !")).to.be.true
			expect(isType('', '')).to.be.true
			expect(isType(' ', ' ')).to.be.true
			expect(isType("Foo", "foo")).to.be.false
			expect(isType("string", "foo")).to.be.false
			expect(isType("String", "foo")).to.be.false
			expect(isType(String, "String")).to.be.false

		it "should return true when value is the same number as the type literal, false if different", ->
			expect(isType(1234, 1234)).to.be.true
			expect(isType(1234.56, 1234.56)).to.be.true
			expect(isType(-1, -1)).to.be.true
			expect(isType(1235, 1234)).to.be.false
			expect(isType(-1234, 1234)).to.be.false
			expect(isType(Number, 1234)).to.be.false

		it "should return true when value is the same boolean as the type literal, false if different", ->
			expect(isType(true, true)).to.be.true
			expect(isType(false, true)).to.be.false
			expect(isType(false, false)).to.be.true
			expect(isType(true, false)).to.be.false
			expect(isType(Boolean, true)).to.be.false
			expect(isType(Boolean, false)).to.be.false

	context "Native Types", ->

		it "should return true for an undefined type, false for other types", ->
			testTypes(undefined, undefined)

		it "should return true for a null type, false for other types", ->
			testTypes(null, null)

		it "should return true for a number type, false for other types", ->
			testTypes(1.1, Number)
			testTypes(0, Number)

		it "should return true for a boolean type, false for other types", ->
			testTypes(true, Boolean)
			testTypes(false, Boolean)

		it "should return true for a string type, false for other types", ->
			testTypes('', String)
			testTypes("Énorme !", String)

		it "should return true for an array type, false for other types", ->
			testTypes([1, 'a'], Array)

		it "should return true for a date type, false for other types", ->
			testTypes(new Date(), Date)

		it "should return true for an object type, false for other types", ->
			testTypes({}, Object)
			testTypes({foo: 'bar'}, Object)

		it "should return true for a set type, false for other types", ->
			testTypes(new Set([]), Set)
			testTypes(new Set([1, 2]), Set)

		it "should return true for a promise type, false for other types", ->
			testTypes(new Promise(->), Promise)
			testTypes(new Promise((resolve, reject) -> resolve()), Promise)

		it "should return true for a function type, false for other types", ->
			testTypes((->), Function)
			testTypes(((a)-> a + 1), Function)

		it "should return true for a factory function value and function type, false for other types", ->
			testTypes(((foo) -> ((bar)-> foo + bar)), Function)
			testTypes(((foo) -> ((bar)-> new Promise((resolve, reject) -> resolve(foo + bar)))), Function)

	context "Object Types", ->

		it "should return true if both value and type are empty object.", ->
			expect(isType({}, {})).to.be.true

		it "should return false if type is empty object but value unempty object.", ->
			expect(isType({a: 1}, {})).to.be.false

		it "should return false if value is empty object but type unempty object.", ->
			expect(isType({}, {a: Number})).to.be.false

		it "should return false for a custom type and non object values", ->
			UserType =
				id: Number
				name: String
			expect(isType(undefined, UserType)).to.be.false
			expect(isType(null, UserType)).to.be.false
			expect(isType(val, UserType)).to.be.false \
				for val in VALUES when val isnt undefined and val isnt null and val.constructor isnt Object

		it "should return true for a shallow custom type, false otherwise", ->
			UserType =
				id: Number
				name: String
			expect(isType({id: 1234, name: "Smith"}, UserType)).to.be.true
			expect(isType({foo: 1234, name: "Smith"}, UserType)).to.be.false
			expect(isType({id: '1234', name: "Smith"}, UserType)).to.be.false
			expect(isType({id: 1234, name: ["Smith"]}, UserType)).to.be.false
			expect(isType({name: "Smith"}, UserType)).to.be.false
			expect(isType({id: 1234}, UserType)).to.be.false
			expect(isType({}, UserType)).to.be.false

		it "should return true for a deep custom type, false otherwise", ->
			UserType =
				id: Number
				name:
					firstName: String
					lastName: String
					middleName: [String, undefined]
			expect(isType({id: 1234, name: {firstName: "John", lastName: "Smith", middleName: "Jack"}}, UserType))
			.to.be.true
			expect(isType({id: 1234, name: {firstName: "John", lastName: "Smith", middleName: 1}}, UserType))
			.to.be.false
			expect(isType({id: 1234, name: {firstName: "John", lastName: "Smith"}}, UserType)).to.be.true
			expect(isType({id: 1234}, UserType)).to.be.false
			expect(isType({name: {firstName: "John", lastName: "Smith"}}, UserType)).to.be.false
			expect(isType({id: 1234, name: {firstName: "John"}}, UserType)).to.be.false
			expect(isType({id: 1234, name: {firstName: "John", lostName: "Smith"}}, UserType)).to.be.false
			expect(isType({id: 1234, name: {firstName: "John", lastName: [1]}}, UserType)).to.be.false
			expect(isType({id: '1234', name: "Smith"}, UserType)).to.be.false
			expect(isType({id: 1234, name: ["Smith"]}, UserType)).to.be.false

		it "should return false for custom type {name: 'Number'} and a number value", ->
			expect(isType(1, {name: 'Number'})).to.be.false

	context "Union Types", ->

		it "should return true if the value is one of the given strings, false otherwise", ->
			expect(isType("foo", ["foo", "bar"])).to.be.true
			expect(isType("bar", ["foo", "bar"])).to.be.true
			expect(isType("baz", ["foo", "bar"])).to.be.false
			expect(isType(Array, ["foo", "bar"])).to.be.false

		it "should return true if the value is one of the given strings, false otherwise", ->
			expect(isType(1, [1, 2])).to.be.true
			expect(isType(2, [1, 2])).to.be.true
			expect(isType(3, [1, 2])).to.be.false
			expect(isType(Array, [1, 2])).to.be.false

		it "should return true for a string or a number value, false otherwise", ->
			expect(isType("foo", [String, Number])).to.be.true
			expect(isType(1234, [String, Number])).to.be.true
			expect(isType(null, [String, Number])).to.be.false
			expect(isType({}, [String, Number])).to.be.false
			expect(isType(new Date(), [Object, Number])).to.be.false

		it "should return true for a string or null value, false otherwise", ->
			expect(isType("foo", [String, null])).to.be.true
			expect(isType(null, [String, null])).to.be.true
			expect(isType(1234, [String, null])).to.be.false

		it "should return true for an object or null value, false otherwise", ->
			expect(isType({id: 1234, name: "Smith"}, [Object, null])).to.be.true
			expect(isType(null, [Object, null])).to.be.true
			expect(isType("foo", [Object, null])).to.be.false

		it "should return true for a custom type or null value, false otherwise", ->
			UserType =
				id: Number
				name: String
			expect(isType({id: 1234, name: "Smith"}, [UserType, null])).to.be.true
			expect(isType(null, [UserType, null])).to.be.true
			expect(isType("foo", [UserType, null])).to.be.false

	context "Typed array", ->

		context "Native Type elements", ->

			it "should return false when value is not an array", ->
				expect(isType(val, Array(Number))).to.be.false for val in VALUES when not Array.isArray(val)
				expect(isType(val, Array(String))).to.be.false for val in VALUES when not Array.isArray(val)

			it "should return true for an array of numbers", ->
				expect(isType([1, 2, 3], Array(Number))).to.be.true
				expect(isType([1], Array(Number))).to.be.true
				expect(isType([], Array(Number))).to.be.true

			it "should return true for an array of strings", ->
				expect(isType(["foo", "bar", "baz"], Array(String))).to.be.true
				expect(isType(["foo"], Array(String))).to.be.true
				expect(isType([], Array(String))).to.be.true

			it "should return false when an element of the array is not a number", ->
				expect(isType([1, val, 3], Array(Number))).to.be.false for val in VALUES when typeof val isnt 'number'
				expect(isType([val], Array(Number))).to.be.false for val in VALUES when typeof val isnt 'number'

			it "should return false when an element of the array is not a string", ->
				expect(isType(["foo", val, "bar"], Array(String))).to.be.false \
					for val in VALUES when typeof val isnt 'string'
				expect(isType([val], Array(String))).to.be.false \
					for val in VALUES when typeof val isnt 'string'

			it "should return true only for empty array or an array of one undefined element
					when type is an array of one empty item", ->
				expect(isType([], Array(1))).to.be.true
				expect(isType([undefined], Array(1))).to.be.true
				expect(isType(undefined, Array(1))).to.be.false
				expect(isType([1], Array(1))).to.be.false

			it "should return false when type is an array of two or more empty items", ->
				expect(isType([undefined], Array(2))).to.be.false
				expect(isType([undefined, undefined], Array(2))).to.be.false
				expect(isType(undefined, Array(2))).to.be.false
				expect(isType([], Array(2))).to.be.false
				expect(isType([1], Array(2))).to.be.false
				expect(isType([undefined], Array(3))).to.be.false
				expect(isType([undefined, undefined, undefined], Array(3))).to.be.false
				expect(isType(undefined, Array(3))).to.be.false
				expect(isType([], Array(3))).to.be.false
				expect(isType([1], Array(3))).to.be.false

		context "Object Type elements", ->

			it "should return false when value is not an array", ->
				nsType = {n: Number, s: String}
				expect(isType(val, Array(nsType))).to.be.false for val in VALUES when not Array.isArray(val)

			it "should return true when all elements of the array are of a given object type", ->
				nsType = {n: Number, s: String}
				expect(isType([{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}], Array(nsType))).to.be.true
				expect(isType([{n: 1, s: "a"}], Array(nsType))).to.be.true
				expect(isType([], Array(nsType))).to.be.true

			it "should return false when some elements of the array are not of a given object type", ->
				nsType = {n: Number, s: String}
				expect(isType([{n: 1, s: "a"}, val, {n: 3, s: "c"}], Array(nsType))).to.be.false for val in VALUES
				expect(isType([val], Array(nsType))).to.be.false for val in VALUES
				expect(isType([{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}], Array(nsType))).to.be.false

		context "Union Type elements", ->

			it "should return false when value is not an array", ->
				expect(isType(val, Array([Number, String]))).to.be.false for val in VALUES when not Array.isArray(val)

			it "should return true for an array whom values are strings or numbers", ->
				expect(isType([], Array([String, Number]))).to.be.true
				expect(isType(["foo", "bar", "baz"], Array([String, Number]))).to.be.true
				expect(isType(["foo"], Array([String, Number]))).to.be.true
				expect(isType([1, 2, 3], Array([String, Number]))).to.be.true
				expect(isType([1], Array([String, Number]))).to.be.true
				expect(isType(["foo", 1, "bar"], Array([String, Number]))).to.be.true
				expect(isType([1, "foo", 2], Array([String, Number]))).to.be.true

			it "should return false when an element of the array is not a string nor a number", ->
				expect(isType(["foo", val, 1], Array([String, Number]))).to.be.false \
					for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
				expect(isType([val], Array([String, Number]))).to.be.false \
					for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'

	context "Custom Types (classes)", ->

		it "should return true type is MyClass, false for other types", ->
			class MyClass
			mc = new MyClass
			testTypes(mc, MyClass)

	context "Unmanaged Types", ->

		it "should throw an error when type is not a native type nor an object nor an array of types
			nor a string or number or boolean literal.", ->
			expect(-> isType(val, new Map([])))
			.to.throw("Type can not be an instance of Map. Use the Map class as type instead.") for val in VALUES


###
	███████╗██╗ ██████╗
	██╔════╝██║██╔════╝
	███████╗██║██║  ███╗
	╚════██║██║██║   ██║
	███████║██║╚██████╔╝
	╚══════╝╚═╝ ╚═════╝
###
describe "sig", ->

	context "Arguments of signature itself", ->

		it "should throw an error if signature is missing its arguments types array", ->
			expect(-> (sig Number, -> 1))
			.to.throw("Array of arguments types is missing.")

		it "should throw an error if signature arguments types array is not an array", ->
			expect(-> (sig Number, Number, -> 1))
			.to.throw("Array of arguments types is missing.")

		it "should throw an error if signature result type is missing", ->
			expect(-> (sig [Number], -> 1))
			.to.throw("Result type is missing.")

		it "should throw an error if signature function to wrap is missing", ->
			expect(-> (sig [Number], Number))
			.to.throw("Function to wrap is missing.")

	context "Synchronous functions", ->

		it "should do nothing if function returns a string", ->
			f = sig [], String,
				-> "foo"
			expect(f()).to.equal("foo")

		it "should throw an error if function returns a number", ->
			f = sig [], String,
				-> 1
			expect(-> f()).to.throw("Result (1) should be of type String instead of Number.")

	context "Asynchronous functions", ->

		it "should return a promise if function returns promise", ->
			f = sig [], promised(Number),
				-> Promise.resolve(1)
			expect(f()?.constructor).to.equal(Promise)

		it "should do nothing if function returns a string promise", ->
			f = sig [], promised(String),
				-> Promise.resolve("foo")
			expect(f()).to.eventually.equal("foo")

		it "should throw an error if function returns a number promise", ->
			f = sig [], promised(String),
				-> Promise.resolve(1)
			expect(f()).to.be.rejectedWith("Promise result (1) should be of type String instead of Number.")

	context "Arguments number", ->

		it "should do nothing if function has the right number of arguments", ->
			f = sig [Number, [Number, String]], [],
				(n1, n2=0) -> n1 + n2
			expect(f(1, 2)).to.equal(3)

		it "should raise an error if function has too many arguments", ->
			f = sig [Number, [Number, String]], [],
				(n1, n2=0) -> n1 + n2
			expect(-> f(1, 2, 3)).to.throw("Too many arguments provided.")

		it "should raise an error if function has too few arguments", ->
			f = sig [Number, [Number, String]], [],
				(n1, n2=0) -> n1 + n2
			expect(-> f(1)).to.throw("Missing required argument number 2.")

		it "should do nothing if all unfilled arguments are optional", ->
			f = sig [Number, [Number, String, undefined]], [],
				(n1, n2=0) -> n1 + n2
			expect(f(1)).to.equal(1)
			expect(f(1, undefined)).to.equal(1)
			f = sig [Number, [Number, String, undefined], Number], [],
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(f(1, undefined, 3)).to.equal(4)

		it "should do nothing if all unfilled arguments type is any type", ->
			f = sig [Number, []], [],
				(n1, n2=0) -> n1 + n2
			expect(f(1)).to.equal(1)
			expect(f(1, undefined)).to.equal(1)
			f = sig [Number, [], Number], [],
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(f(1, undefined, 3)).to.equal(4)

		it "should raise an error if some unfilled arguments are not optional", ->
			f = sig [Number, [Number, String, undefined], Number], [],
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(-> f(1)).to.throw("Missing required argument number 3.")
			expect(-> f(1, 2)).to.throw("Missing required argument number 3.")

		it "should raise an error when an optional argument is filled with null", ->
			f = sig [Number, [Number, undefined]], [],
				(n1, n2=0) -> n1 + n2
			expect(-> f(1, null))
			.to.throw("Argument number 2 (null) should be of type Number or undefined instead of null")

		it "should raise an error when only an optional argument and value is null", ->
			f = sig [undefined], [],
				(n1=0) -> n1
			expect(-> f(null)).to.throw("Argument number 1 (null) should be of type undefined instead of null.")

		it "should raise an error when only an optional argument and value isnt undefined", ->
			f = sig [undefined], [],
				(n1=0) -> n1
			expect(-> f(1)).to.throw("Argument number 1 (1) should be of type undefined instead of Number.")

		it "should do nothing if only an optional argument and value is undefined", ->
			f = sig [undefined], [],
				(n1=0) -> n1
			expect(f(undefined)).to.equal(0)

		it "should do nothing if only an optional argument and value is not filled", ->
			f = sig [undefined], [],
				(n1=0) -> n1
			expect(f()).to.equal(0)

	context "Splats", ->

		it "should return the concatenation of zero argument of String type", ->
			f = sig [etc(String)], String,
				(str...) -> str.join('')
			expect(f()).to.equal('')
			f = sig [Number, etc(String)], String,
				(n, str...) -> n + str.join('')
			expect(f(1)).to.equal('1')

		it "should return the concatenation of one argument of String type", ->
			f = sig [etc(String)], String,
				(str...) -> str.join('')
			expect(f('abc')).to.equal('abc')
			f = sig [Number, etc(String)], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'abc')).to.equal('1abc')

		it "should return the concatenation of all the arguments of String type", ->
			f = sig [etc(String)], String,
				(str...) -> str.join('')
			expect(f('a', 'bc', 'def')).to.equal('abcdef')
			f = sig [Number, etc(String)], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 'bc', 'def')).to.equal('1abcdef')

		it "should throw an error if an argument is not a string", ->
			f = sig [etc(String)], String,
				(str...) -> str.join('')
			expect(-> f('a', 5, 'def'))
			.to.throw("Argument number 2 (5) should be of type String instead of Number.")
			f = sig [Number, etc(String)], String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 5, 'def'))
			.to.throw("Argument number 3 (5) should be of type String instead of Number.")

		it "should throw an error if an argument is not a number", ->
			f = sig [etc(Number)], String,
				(str...) -> str.join('')
			expect(-> f('a', 5, 'def'))
			.to.throw("Argument number 1 (a) should be of type Number instead of String.")
			f = sig [Number, etc(Number)], String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 5, 'def'))
			.to.throw("Argument number 2 (a) should be of type Number instead of String.")

		it "should return the concatenation of all the arguments of any type", ->
			f = sig [etc([])], String,
				(str...) -> str.join('')
			expect(f('a', 5, 'def')).to.equal('a5def')
			f = sig [Number, etc([])], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 5, 'def')).to.equal('1a5def')

		it "should return the concatenation of all the arguments of String or Number type", ->
			f = sig [etc([String, Number])], String,
				(str...) -> str.join('')
			expect(f('a', 1, 'def')).to.equal('a1def')
			f = sig [Number, etc([String, Number])], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 2, 'def')).to.equal('1a2def')

		it "should throw an error if an argument is not a string or a Number type", ->
			f = sig [etc([String, Number])], String,
				(str...) -> str.join('')
			expect(-> f('a', true, 'def'))
			.to.throw("Argument number 2 (true) should be of type String or Number instead of Boolean.")
			f = sig [Number, etc([String, Number])], String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', true, 'def'))
			.to.throw("Argument number 3 (true) should be of type String or Number instead of Boolean.")

		# ### CoffeeScript only ###
		# it "should NOT throw an error if splat is not the last of the argument types", ->
		# 	f = sig [Number, etc(String)], String,
		# 		(n, str...) -> n + str.join('')
		# 	expect(f(1, 'a', 'b', 'c')).to.equal("abc1")
		# 	f = sig [etc(String), Number], String,
		# 		(str..., n) -> str.join('') + n
		# 	expect(f('a', 'b', 'c', 1)).to.equal("abc1")
		# 	f = sig [Number, etc(String), Number], String,
		# 		(n1, str..., n2) -> n1 + str.join('') + n2
		# 	expect(f(1, 'a', 'b', 'c', 2)).to.equal("1abc2")

		it "should throw an error if rest type is not the last of the argument types", ->
			f = sig [etc(String), String], String,
				(str...) -> str.join('')
			expect(-> f('a', 'bc', 'def'))
			.to.throw("Rest type must be the last of the arguments types.")
			f = sig [Number, etc(String), String], String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 'bc', 'def'))
			.to.throw("Rest type must be the last of the arguments types.")
