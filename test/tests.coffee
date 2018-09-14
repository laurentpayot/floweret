# testing the build, minified, not the source
{typeOf, isType, isAnyType, fn, promised, etc} = require '../dist/runtime-signature.min.js'

{Type} = require '../dist/types'
maybe = require '../dist/types/maybe'
AnyType = require '../dist/types/AnyType'
EmptyArray = require '../dist/types/EmptyArray'
Integer = require '../dist/types/Integer'
Natural = require '../dist/types/Natural'
Tuple = require '../dist/types/Tuple'
TypedObject = require '../dist/types/TypedObject'
TypedSet = require '../dist/types/TypedSet'
TypedMap = require '../dist/types/TypedMap'

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
	new Map([[ 1, 'one' ], [ 2, 'two' ]])
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
describe "typeOf (add more tests!!!)", ->

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
	██╗███████╗ █████╗ ███╗   ██╗██╗   ██╗████████╗██╗   ██╗██████╗ ███████╗
	██║██╔════╝██╔══██╗████╗  ██║╚██╗ ██╔╝╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
	██║███████╗███████║██╔██╗ ██║ ╚████╔╝    ██║    ╚████╔╝ ██████╔╝█████╗
	██║╚════██║██╔══██║██║╚██╗██║  ╚██╔╝     ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
	██║███████║██║  ██║██║ ╚████║   ██║      ██║      ██║   ██║     ███████╗
	╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝      ╚═╝      ╚═╝   ╚═╝     ╚══════╝
###
describe "isAnyType", ->

	it "should return false for native types", ->
		expect(isAnyType(t)).to.be.false for t in NATIVE_TYPES

	it "should return true for empty array", ->
		expect(isAnyType([])).to.be.true

	it "should return true for AnyType", ->
		expect(isAnyType(AnyType)).to.be.true

	it "should return true for AnyType()", ->
		expect(isAnyType(AnyType())).to.be.true

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

		context "EmptyArray type", ->

			it "EmptyArray type should return true for empty array only", ->
				expect(isType([], EmptyArray)).to.be.true
				expect(isType(v, EmptyArray)).to.be.false for v in VALUES when not (Array.isArray(v) and not v.length)

			it "EmptyArray() type should return true for empty array only", ->
				expect(isType([], EmptyArray())).to.be.true
				expect(isType(v, EmptyArray())).to.be.false for v in VALUES when not (Array.isArray(v) and not v.length)

		context "Any type", ->

			it "empty array type should return true for all values", ->
				expect(isType(val, [])).to.be.true for val in VALUES

			it "AnyType type should return true for all values", ->
				expect(isType(val, AnyType)).to.be.true for val in VALUES

			it "AnyType() type should return true for all values", ->
				expect(isType(val, AnyType())).to.be.true for val in VALUES

			it "AnyType(Number) type should throw an error", ->
				expect(-> isType(1, AnyType(Number))).to.throw("'AnyType' cannot have any arguments.")

			it "AnyType([]) type should throw an error", ->
				expect(-> isType(1, AnyType([]))).to.throw("'AnyType' cannot have any arguments.")

		context "Maybe type", ->

			it "maybe([]) should return empty array.", ->
				expect(maybe([])).to.be.an('array').that.is.empty

			it "maybe(AnyType) should return empty array.", ->
				expect(maybe(AnyType)).to.be.an('array').that.is.empty

			it "maybe(Number, [], String) should return empty array.", ->
				expect(maybe(Number, [], String)).to.be.an('array').that.is.empty

			it "maybe(Number, AnyType) should return empty array.", ->
				expect(maybe(Number, AnyType, String)).to.be.an('array').that.is.empty

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

			it "should return true for a Number or a String or undefined or null", ->
				expect(isType(1, maybe(Number, String))).to.be.true
				expect(isType('1', maybe(Number, String))).to.be.true
				expect(isType(undefined, maybe(Number, String))).to.be.true
				expect(isType(null, maybe(Number, String))).to.be.true

			it "should return true for a Number or a String or undefined or null, when union is used", ->
				expect(isType(1, maybe([Number, String]))).to.be.true
				expect(isType('1', maybe([Number, String]))).to.be.true
				expect(isType(undefined, maybe([Number, String]))).to.be.true
				expect(isType(null, maybe([Number, String]))).to.be.true

			it "maybe() should throw an error when type is ommited", ->
				expect(-> isType(1, maybe()))
				.to.be.throw("'maybe' must have at least 1 argument.")

			it "maybe should throw an error when used as a function", ->
				expect(-> isType(1, maybe)).to.throw("'maybe' must have at least 1 argument")

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

		it "should return true if type is empty object but value unempty object.", ->
			expect(isType({a: 1}, {})).to.be.true

		it "should return false if value is empty object but type unempty object.", ->
			expect(isType({}, {a: Number})).to.be.false

		it "should return true if same object type but one more key.", ->
			expect(isType({a: 1, b: 2, c: 'foo'}, {a: Number, b: Number})).to.be.true

		it "should return false if same object type but one key less.", ->
			expect(isType({a: 1}, {a: Number, b: Number})).to.be.false

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
			expect(isType({id: 1234, name: "Smith", foo: "bar"}, UserType)).to.be.true
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

	context "Sized Array", ->

		it "should return false for empty array", ->
			expect(isType([], Array(1))).to.be.false
			expect(isType([], Array(2))).to.be.false
			expect(isType([], Array(3))).to.be.false

		it "should return true for same size array of undefined", ->
			expect(isType([undefined], Array(1))).to.be.true
			expect(isType([undefined, undefined], Array(2))).to.be.true
			expect(isType([undefined, undefined, undefined], Array(3))).to.be.true

		it "should return true for same size array of anything", ->
			expect(isType([1], Array(1))).to.be.true
			expect(isType([1, true], Array(2))).to.be.true
			expect(isType([undefined, true], Array(2))).to.be.true
			expect(isType([1, true, "three"], Array(3))).to.be.true
			expect(isType([1, true, "tree"], Array(3))).to.be.true
			expect(isType([undefined, true, "tree"], Array(3))).to.be.true
			expect(isType([1, undefined, "tree"], Array(3))).to.be.true

		it "should return false for different size array of anything", ->
			expect(isType([1], Array(2))).to.be.false
			expect(isType([1, true], Array(3))).to.be.false
			expect(isType([1, 1], Array(3))).to.be.false
			expect(isType([undefined, true], Array(4))).to.be.false
			expect(isType([1, 1, 1], Array(4))).to.be.false
			expect(isType([1, true, "three"], Array(4))).to.be.false
			expect(isType([1, true, "tree"], Array(4))).to.be.false
			expect(isType([undefined, true, "tree"], Array(4))).to.be.false
			expect(isType([1, undefined, "tree"], Array(4))).to.be.false


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

	context "Custom types", ->

		it "should throw an error when creating an instance of Type", ->
			expect(-> new Type()).to.throw("Abstract class 'Type' cannot be instantiated directly.")

		context "Integer type", ->

			it "should throw an error when Integer arguments are not numers", ->
				expect(-> isType(1, Integer('100'))).to.throw("Integer arguments must be numbers.")
				expect(-> isType(1, Integer(1, '100'))).to.throw("Integer arguments must be numbers.")
				expect(-> isType(1, Integer('1', 100))).to.throw("Integer arguments must be numbers.")
				expect(-> isType(1, Integer('1', '100'))).to.throw("Integer arguments must be numbers.")

			it "should not throw an error when Integer is used as a function", ->
				expect(isType(1, Integer)).to.be.true

			it "should not throw an error when Integer is used without arguments", ->
				expect(isType(1, Integer())).to.be.true

			it "should return true for an integer number", ->
				expect(isType(1, Integer)).to.be.true
				expect(isType(0, Integer)).to.be.true
				expect(isType(-0, Integer)).to.be.true
				expect(isType(-1, Integer)).to.be.true

			it "should return false for an decimal number", ->
				expect(isType(1.1, Integer)).to.be.false
				expect(isType(0.1, Integer)).to.be.false
				expect(isType(-0.1, Integer)).to.be.false
				expect(isType(-1.1, Integer)).to.be.false

		context "Natural type", ->

			it "should throw an error when Natural arguments are not numers", ->
				expect(-> isType(1, Natural('100'))).to.throw("Natural arguments must be numbers.")

			it "should return false for an negative integer", ->
				expect(isType(-1, Natural)).to.be.false

			it "should return true for an positive integer", ->
				expect(isType(1, Natural)).to.be.true

			it "should return true for zero", ->
				expect(isType(0, Natural)).to.be.true
				expect(isType(-0, Natural)).to.be.true

		context "Tuple type", ->

			it "should throw an error when Tuple is used as a function", ->
				expect(-> isType(1, Tuple)).to.throw("'Tuple' must have at least 2 arguments.")

			it "should throw an error when Tuple is used without arguments", ->
				expect(-> isType(1, Tuple())).to.throw("'Tuple' must have at least 2 arguments.")

			context "Any Type elements", ->

				it "Tuple of [] should return array of empty elements", ->
					t = Tuple([], [])
					expect(t).to.be.an('array').that.is.not.empty
					expect(t).to.have.lengthOf(2)
					expect(t[0]).to.be.undefined
					expect(t[1]).to.be.undefined

				it "Tuple of AnyType should return array of empty elements", ->
					t = Tuple(AnyType, AnyType)
					expect(t).to.be.an('array').that.is.not.empty
					expect(t).to.have.lengthOf(2)
					expect(t[0]).to.be.undefined
					expect(t[1]).to.be.undefined

				it "Tuple of AnyType() should return array of empty elements", ->
					t = Tuple(AnyType(), AnyType())
					expect(t).to.be.an('array').that.is.not.empty
					expect(t).to.have.lengthOf(2)
					expect(t[0]).to.be.undefined
					expect(t[1]).to.be.undefined


			context "Native Type elements", ->

				it "should return true when value is an array correspondig to Tuple type", ->
					expect(isType([1, true, "three"], Tuple(Number, Boolean, String))).to.be.true

				it "should return false when value is an array not correspondig to Tuple type", ->
					expect(isType(["1", true, "three"], Tuple(Number, Boolean, String))).to.be.false

				it "should return false when value is a number", ->
					expect(isType(1, Tuple(Number, Boolean, String))).to.be.false

				it "should return false when value is an empty array", ->
					expect(isType([], Tuple(Number, Boolean, String))).to.be.false

		context "Typed object", ->

			it "should throw an error when TypedObject is used as a function", ->
				expect(-> isType(1, TypedObject)).to.throw("'TypedObject' must have exactly 1 argument.")

			it "should throw an error when TypedObject is used without arguments", ->
				expect(-> isType(1, TypedObject())).to.throw("'TypedObject' must have exactly 1 argument.")

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

		context "Typed set", ->

			context "Any type elements", ->

				it "TypedSet() should throw an error", ->
					expect(-> TypedSet()).to.throw("'TypedSet' must have exactly 1 argument.")

				it "TypedSet used as a function should throw an error.", ->
					expect(-> isType(1, TypedSet)).to.throw("'TypedSet' must have exactly 1 argument.")

				it "TypedSet([]) should return Set type.", ->
					expect(TypedSet([])).to.equal(Set)

				it "TypedSet(AnyType) should return Set type.", ->
					expect(TypedSet(AnyType)).to.equal(Set)

			context "Native Type elements", ->

				it "should return false when value is not a set", ->
					expect(isType(val, TypedSet(Number))).to.be.false for val in VALUES when not val?.constructor is Set
					expect(isType(val, TypedSet(String))).to.be.false for val in VALUES when not val?.constructor is Set

				it "should return true for a set of numbers", ->
					expect(isType(new Set([1, 2, 3]), TypedSet(Number))).to.be.true
					expect(isType(new Set([1]), TypedSet(Number))).to.be.true
					expect(isType(new Set([]), TypedSet(Number))).to.be.true

				it "should return true for a set of strings", ->
					expect(isType(new Set(["foo", "bar", "baz"]), TypedSet(String))).to.be.true
					expect(isType(new Set(["foo"]), TypedSet(String))).to.be.true
					expect(isType(new Set([]), TypedSet(String))).to.be.true

				it "should return false when an element of the set is not a number", ->
					expect(isType(new Set([1, val, 3]), TypedSet(Number))).to.be.false for val in VALUES when typeof val isnt 'number'
					expect(isType(new Set([val]), TypedSet(Number))).to.be.false for val in VALUES when typeof val isnt 'number'

				it "should return false when an element of the set is not a string", ->
					expect(isType(new Set(["foo", val, "bar"]), TypedSet(String))).to.be.false \
						for val in VALUES when typeof val isnt 'string'
					expect(isType(new Set([val]), TypedSet(String))).to.be.false \
						for val in VALUES when typeof val isnt 'string'

			context "Object Type elements", ->

				it "should return false when value is not a set", ->
					nsType = {n: Number, s: String}
					expect(isType(val, TypedSet(nsType))).to.be.false for val in VALUES when not val?.constructor is Set

				it "should return true when all elements of the set are of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isType(new Set([{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}]), TypedSet(nsType))).to.be.true
					expect(isType(new Set([{n: 1, s: "a"}]), TypedSet(nsType))).to.be.true
					expect(isType(new Set([]), TypedSet(nsType))).to.be.true

				it "should return false when some elements of the set are not of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isType(new Set([{n: 1, s: "a"}, val, {n: 3, s: "c"}]), TypedSet(nsType))).to.be.false for val in VALUES
					expect(isType(new Set([val]), TypedSet(nsType))).to.be.false for val in VALUES
					expect(isType(new Set([{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}]), TypedSet(nsType))).to.be.false

			context "Union Type elements", ->

				it "should return false when value is not a set", ->
					expect(isType(val, TypedSet([Number, String]))).to.be.false for val in VALUES when not val?.constructor is Set

				it "should return true for a set whom values are strings or numbers", ->
					expect(isType(new Set([]), TypedSet([String, Number]))).to.be.true
					expect(isType(new Set(["foo", "bar", "baz"]), TypedSet([String, Number]))).to.be.true
					expect(isType(new Set(["foo"]), TypedSet([String, Number]))).to.be.true
					expect(isType(new Set([1, 2, 3]), TypedSet([String, Number]))).to.be.true
					expect(isType(new Set([1]), TypedSet([String, Number]))).to.be.true
					expect(isType(new Set(["foo", 1, "bar"]), TypedSet([String, Number]))).to.be.true
					expect(isType(new Set([1, "foo", 2]), TypedSet([String, Number]))).to.be.true

				it "should return false when an element of the set is not a string nor a number", ->
					expect(isType(new Set(["foo", val, 1]), TypedSet([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
					expect(isType(new Set([val]), TypedSet([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'

		context "Typed map", ->

			context "Any type elements", ->

				it "TypedMap() should throw an error.", ->
					expect(-> TypedMap()).to.throw("'TypedMap' must have at least 1 argument.")

				it "TypedMap used as a function should throw an error.", ->
					expect(-> isType(1, TypedMap)).to.throw("'TypedMap' must have at least 1 argument.")

				it "TypedMap([]) should return Map type.", ->
					expect(TypedMap([])).to.equal(Map)

				it "TypedMap([], []) should return Map type.", ->
					expect(TypedMap([], [])).to.equal(Map)

				it "TypedMap(AnyType) should return Map type.", ->
					expect(TypedMap(AnyType)).to.equal(Map)

				it "TypedMap(AnyType, AnyType) should return Map type.", ->
					expect(TypedMap(AnyType, AnyType)).to.equal(Map)

			context "Native Type elements", ->

				it "should return false when value is not a Map", ->
					expect(isType(val, TypedMap(Number))).to.be.false for val in VALUES when not val?.constructor is Map
					expect(isType(val, TypedMap(String))).to.be.false for val in VALUES when not val?.constructor is Map
					expect(isType(val, TypedMap(Number, String))).to.be.false for val in VALUES when not val?.constructor is Map
					expect(isType(val, TypedMap(String, Number))).to.be.false for val in VALUES when not val?.constructor is Map

				it "should return true for a Map of numbers", ->
					expect(isType(new Map([['one', 1], ['two', 2], ['three', 3]]), TypedMap(Number))).to.be.true
					expect(isType(new Map([['one', 1]]), TypedMap(Number))).to.be.true
					expect(isType(new Map([]), TypedMap(Number))).to.be.true

				it "should return true for a Map of strings -> numbers", ->
					expect(isType(new Map([['one', 1], ['two', 2], ['three', 3]]), TypedMap(String, Number))).to.be.true
					expect(isType(new Map([['one', 1]]), TypedMap(String, Number))).to.be.true
					expect(isType(new Map([]), TypedMap(String, Number))).to.be.true

				it "should return true for a Map of strings", ->
					expect(isType(new Map([[1, 'one'], [2, 'two'], [3, 'three']]), TypedMap(String))).to.be.true
					expect(isType(new Map([[1, 'one']]), TypedMap(String))).to.be.true
					expect(isType(new Map([]), TypedMap(String))).to.be.true

				it "should return true for a Map of numbers -> strings", ->
					expect(isType(new Map([[1, 'one'], [2, 'two'], [3, 'three']]), TypedMap(Number, String))).to.be.true
					expect(isType(new Map([[1, 'one']]), TypedMap(Number, String))).to.be.true
					expect(isType(new Map([]), TypedMap(Number, String))).to.be.true

				it "should return false when an element of the Map is not a number", ->
					expect(isType(new Map([['one', 1], ['two', val], ['three', 3]]), TypedMap(Number)))
					.to.be.false for val in VALUES when typeof val isnt 'number'
					expect(isType(new Map([['foo', val]]), TypedMap(Number)))
					.to.be.false for val in VALUES when typeof val isnt 'number'

				it "should return false when an element of the Map is not a string", ->
					expect(isType(new Map([[1, 'one'], [2, val], [3, 'three']]), TypedMap(String)))
					.to.be.false for val in VALUES when typeof val isnt 'string'
					expect(isType(new Map([[1234, val]]), TypedMap(String)))
					.to.be.false for val in VALUES when typeof val isnt 'string'

				it "should return false when a value of the Map number -> string is not a string", ->
					expect(isType(new Map([[1, 'one'], [2, val], [3, 'three']]), TypedMap(Number, String)))
					.to.be.false for val in VALUES when typeof val isnt 'string'
					expect(isType(new Map([[1234, val]]), TypedMap(Number, String)))
					.to.be.false for val in VALUES when typeof val isnt 'string'

				it "should return false when a key of the Map number -> string is not a string", ->
					expect(isType(new Map([[1, 'one'], [val, 'two'], [3, 'three']]), TypedMap(Number, String)))
					.to.be.false for val in VALUES when typeof val isnt 'number'
					expect(isType(new Map([[val, 'foo']]), TypedMap(Number, String)))
					.to.be.false for val in VALUES when typeof val isnt 'number'

			context.skip "Object Type elements", ->

				it "should return false when value is not a Map", ->
					nsType = {n: Number, s: String}
					expect(isType(val, TypedMap(nsType))).to.be.false for val in VALUES when not val?.constructor is Map

				it "should return true when all elements of the Map are of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isType(new Map([{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}]), TypedMap(nsType))).to.be.true
					expect(isType(new Map([{n: 1, s: "a"}]), TypedMap(nsType))).to.be.true
					expect(isType(new Map([]), TypedMap(nsType))).to.be.true

				it "should return false when some elements of the Map are not of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isType(new Map([{n: 1, s: "a"}, val, {n: 3, s: "c"}]), TypedMap(nsType))).to.be.false for val in VALUES
					expect(isType(new Map([val]), TypedMap(nsType))).to.be.false for val in VALUES
					expect(isType(new Map([{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}]), TypedMap(nsType))).to.be.false

			context.skip "Union Type elements", ->

				it "should return false when value is not a Map", ->
					expect(isType(val, TypedMap([Number, String]))).to.be.false for val in VALUES when not val?.constructor is Map

				it "should return true for a Map whom values are strings or numbers", ->
					expect(isType(new Map([]), TypedMap([String, Number]))).to.be.true
					expect(isType(new Map(["foo", "bar", "baz"]), TypedMap([String, Number]))).to.be.true
					expect(isType(new Map(["foo"]), TypedMap([String, Number]))).to.be.true
					expect(isType(new Map([1, 2, 3]), TypedMap([String, Number]))).to.be.true
					expect(isType(new Map([1]), TypedMap([String, Number]))).to.be.true
					expect(isType(new Map(["foo", 1, "bar"]), TypedMap([String, Number]))).to.be.true
					expect(isType(new Map([1, "foo", 2]), TypedMap([String, Number]))).to.be.true

				it "should return false when an element of the Map is not a string nor a number", ->
					expect(isType(new Map(["foo", val, 1]), TypedMap([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
					expect(isType(new Map([val]), TypedMap([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'

	context "Promised type", ->

		it "should throw an error for a promised number.", ->
			expect(-> isType(Promise.resolve(1), Promise.resolve(Number)))
			.to.throw("Type can not be an instance of Promise. Use Promise as type instead.")
			expect(-> isType(Promise.resolve(1), promised(Number)))
			.to.throw("Type can not be an instance of Promise. Use Promise as type instead.")

	context "Custom type (class)", ->

		it "should return true when type is MyClass, false for other types", ->
			class MyClass
			mc = new MyClass
			testTypes(mc, MyClass)

	context "Unmanaged Types", ->

		it "should throw an error when etc is used as a function", ->
			expect(-> isType(1, etc))
			.to.throw("'etc' can not be used in types.")

		it "should throw an error when etc is used without parameter", ->
			expect(-> isType(1, etc()))
			.to.throw("'etc' can not be used in types.")

		it "should throw an error when type is not a native type nor an object nor an array of types
			nor a string or number or boolean literal.", ->
			expect(-> isType(val, Symbol("foo")))
			.to.throw("Type can not be an instance of Symbol. Use Symbol as type instead.") for val in VALUES

###
	███████╗███╗   ██╗
	██╔════╝████╗  ██║
	█████╗  ██╔██╗ ██║
	██╔══╝  ██║╚██╗██║
	██║     ██║ ╚████║
	╚═╝     ╚═╝  ╚═══╝
###
describe "fn", ->

	context "Arguments of signature itself", ->

		it "should throw an error if signature is missing its arguments types array", ->
			expect(-> (fn Number, -> 1))
			.to.throw("Array of arguments types is missing.")

		it "should throw an error if signature arguments types array is not an array", ->
			expect(-> (fn Number, Number, -> 1))
			.to.throw("Array of arguments types is missing.")

		it "should throw an error if signature result type is missing", ->
			expect(-> (fn [Number], -> 1))
			.to.throw("Result type is missing.")

		it "should throw an error if signature function to wrap is missing", ->
			expect(-> (fn [Number], Number))
			.to.throw("Function to wrap is missing.")

	context "Synchronous functions", ->

		it "should do nothing if function returns a string", ->
			f = fn [], String,
				-> "foo"
			expect(f()).to.equal("foo")

		it "should throw an error if function returns a number", ->
			f = fn [], String,
				-> 1
			expect(-> f()).to.throw("Result (1) should be of type String instead of Number.")

		it "should throw an error if function returns undefined", ->
			f = fn [], [String, Number],
				->
			expect(-> f()).to.throw("Result (undefined) should be of type String or Number instead of undefined.")

	context "Asynchronous functions", ->

		it "should return a promise if function returns promise", ->
			f = fn [], promised(Number),
				-> Promise.resolve(1)
			expect(f()?.constructor).to.equal(Promise)

		it "should do nothing if function returns a string promise", ->
			f = fn [], promised(String),
				-> Promise.resolve("foo")
			expect(f()).to.eventually.equal("foo")

		it "should throw an error if function returns a number promise", ->
			f = fn [], promised(String),
				-> Promise.resolve(1)
			expect(f()).to.be.rejectedWith("Promise result (1) should be of type String instead of Number.")

		it "should throw an error if promised used without type", ->
			expect(-> fn [], promised(),
				-> Promise.resolve(1)
			).to.throw("'promised' must have exactly 1 argument.")

		it "should throw an error if promised used as a function", ->
			f = fn [], promised,
				-> Promise.resolve(1)
			expect(-> f()).to.throw("'promised' can not be used directly as a function.")

	context "Arguments number", ->

		it "should do nothing if function has the right number of arguments", ->
			f = fn [Number, [Number, String]], [],
				(n1, n2=0) -> n1 + n2
			expect(f(1, 2)).to.equal(3)

		it "should raise an error if function has too many arguments", ->
			f = fn [Number, [Number, String]], [],
				(n1, n2=0) -> n1 + n2
			expect(-> f(1, 2, 3)).to.throw("Too many arguments provided.")

		it "should raise an error if function has too few arguments", ->
			f = fn [Number, [Number, String]], [],
				(n1, n2=0) -> n1 + n2
			expect(-> f(1)).to.throw("Missing required argument number 2.")

		it "should do nothing if all unfilled arguments are optional", ->
			f = fn [Number, [Number, String, undefined]], [],
				(n1, n2=0) -> n1 + n2
			expect(f(1)).to.equal(1)
			expect(f(1, undefined)).to.equal(1)
			f = fn [Number, [Number, String, undefined], Number], [],
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(f(1, undefined, 3)).to.equal(4)

		it "should do nothing if all unfilled arguments type is any type", ->
			f = fn [Number, []], [],
				(n1, n2=0) -> n1 + n2
			expect(f(1)).to.equal(1)
			expect(f(1, undefined)).to.equal(1)
			f = fn [Number, [], Number], [],
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(f(1, undefined, 3)).to.equal(4)

		it "should raise an error if some unfilled arguments are not optional", ->
			f = fn [Number, [Number, String, undefined], Number], [],
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(-> f(1)).to.throw("Missing required argument number 3.")
			expect(-> f(1, 2)).to.throw("Missing required argument number 3.")

		it "should raise an error when an optional argument is filled with null", ->
			f = fn [Number, [Number, undefined]], [],
				(n1, n2=0) -> n1 + n2
			expect(-> f(1, null))
			.to.throw("Argument number 2 (null) should be of type Number or undefined instead of null")

		it "should raise an error when only an optional argument and value is null", ->
			f = fn [undefined], [],
				(n1=0) -> n1
			expect(-> f(null)).to.throw("Argument number 1 (null) should be of type undefined instead of null.")

		it "should raise an error when only an optional argument and value isnt undefined", ->
			f = fn [undefined], [],
				(n1=0) -> n1
			expect(-> f(1)).to.throw("Argument number 1 (1) should be of type undefined instead of Number.")

		it "should do nothing if only an optional argument and value is undefined", ->
			f = fn [undefined], [],
				(n1=0) -> n1
			expect(f(undefined)).to.equal(0)

		it "should do nothing if only an optional argument and value is not filled", ->
			f = fn [undefined], [],
				(n1=0) -> n1
			expect(f()).to.equal(0)

	context "Rest type", ->

		it "should return the concatenation of zero argument of String type", ->
			f = fn [etc(String)], String,
				(str...) -> str.join('')
			expect(f()).to.equal('')
			f = fn [Number, etc(String)], String,
				(n, str...) -> n + str.join('')
			expect(f(1)).to.equal('1')

		it "should return the concatenation of one argument of String type", ->
			f = fn [etc(String)], String,
				(str...) -> str.join('')
			expect(f('abc')).to.equal('abc')
			f = fn [Number, etc(String)], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'abc')).to.equal('1abc')

		it "should return the concatenation of all the arguments of String type", ->
			f = fn [etc(String)], String,
				(str...) -> str.join('')
			expect(f('a', 'bc', 'def')).to.equal('abcdef')
			f = fn [Number, etc(String)], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 'bc', 'def')).to.equal('1abcdef')

		it "should throw an error if an argument is not a string", ->
			f = fn [etc(String)], String,
				(str...) -> str.join('')
			expect(-> f('a', 5, 'def'))
			.to.throw("Argument number 2 (5) should be of type String instead of Number.")
			f = fn [Number, etc(String)], String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 5, 'def'))
			.to.throw("Argument number 3 (5) should be of type String instead of Number.")

		it "should throw an error if an argument is not a number", ->
			f = fn [etc(Number)], String,
				(str...) -> str.join('')
			expect(-> f('a', 5, 'def'))
			.to.throw("Argument number 1 (a) should be of type Number instead of String.")
			f = fn [Number, etc(Number)], String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 5, 'def'))
			.to.throw("Argument number 2 (a) should be of type Number instead of String.")

		it "should return the concatenation of all the arguments of String or Number type", ->
			f = fn [etc([String, Number])], String,
				(str...) -> str.join('')
			expect(f('a', 1, 'def')).to.equal('a1def')
			f = fn [Number, etc([String, Number])], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 2, 'def')).to.equal('1a2def')

		it "should throw an error if an argument is not a string or a Number type", ->
			f = fn [etc([String, Number])], String,
				(str...) -> str.join('')
			expect(-> f('a', true, 'def'))
			.to.throw("Argument number 2 (true) should be of type String or Number instead of Boolean.")
			f = fn [Number, etc([String, Number])], String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', true, 'def'))
			.to.throw("Argument number 3 (true) should be of type String or Number instead of Boolean.")

		# ### CoffeeScript only ###
		# it "should NOT throw an error if splat is not the last of the argument types", ->
		# 	f = fn [Number, etc(String)], String,
		# 		(n, str...) -> n + str.join('')
		# 	expect(f(1, 'a', 'b', 'c')).to.equal("abc1")
		# 	f = fn [etc(String), Number], String,
		# 		(str..., n) -> str.join('') + n
		# 	expect(f('a', 'b', 'c', 1)).to.equal("abc1")
		# 	f = fn [Number, etc(String), Number], String,
		# 		(n1, str..., n2) -> n1 + str.join('') + n2
		# 	expect(f(1, 'a', 'b', 'c', 2)).to.equal("1abc2")

		it "should throw an error if rest type is not the last of the argument types", ->
			f = fn [etc(String), String], String,
				(str...) -> str.join('')
			expect(-> f('a', 'bc', 'def'))
			.to.throw("Rest type must be the last of the arguments types.")
			f = fn [Number, etc(String), String], String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 'bc', 'def'))
			.to.throw("Rest type must be the last of the arguments types.")

		it "should return the concatenation of all the arguments of any type", ->
			f = fn [etc([])], String,
				(str...) -> str.join('')
			expect(f('a', 5, 'def')).to.equal('a5def')
			f = fn [Number, etc([])], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 5, 'def')).to.equal('1a5def')

		it "should behave like etc([]) when type is ommited", ->
			f = fn [etc()], String,
				(str...) -> str.join('')
			expect(f('a', 5, 'def')).to.equal('a5def')
			f = fn [Number, etc()], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 5, 'def')).to.equal('1a5def')

		it "should behave like etc([]) when used as a function", ->
			f = fn [etc], String,
				(str...) -> str.join('')
			expect(f('a', 5, 'def')).to.equal('a5def')
			f = fn [Number, etc], String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 5, 'def')).to.equal('1a5def')

	context "Error messages", ->

		context "Uncomposed type argument", ->

			it "should return an error with 'undefined'", ->
				f = fn [undefined], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type undefined instead of Number.")

			it "should return an error with 'null'", ->
				f = fn [null], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type null instead of Number.")

			it "should return an error with 'String'", ->
				f = fn [String], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type String instead of Number.")

			it "should return an error with 'Array'", ->
				f = fn [Array], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type Array instead of Number.")

			it "should return an error with 'literal String 'foo'", ->
				f = fn ['foo'], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type literal String 'foo' instead of Number.")

			it "should return an error with 'literal Number '1'", ->
				f = fn [1], AnyType, ->
				expect( -> f('1'))
				.to.throw("Argument number 1 (1) should be of type literal Number '1' instead of String.")

			it "should return an error with 'literal Boolean 'true'", ->
				f = fn [true], AnyType, ->
				expect( -> f(false))
				.to.throw("Argument number 1 (false) should be of type literal Boolean 'true' instead of Boolean.")

			it "should return an error with
				'Argument number 1 should be an object with key 'a.c' of type String instead of Number.'", ->
				f = fn [{a: {b: Number, c: String}, d: Number}], AnyType, ->
				expect( -> f(a: {b: 1, c: 2}, d: 3))
				.to.throw("Argument number 1 should be an object with key 'a.c'
							of type String instead of Number.")

			it "should return an error with 'MyClass", ->
				class MyClass
				f = fn [MyClass], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type MyClass instead of Number.")

			it "should return an error with 'empty array'", ->
				f = fn [EmptyArray], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type empty array instead of Number.")
				expect( -> f([1]))
				.to.throw("Argument number 1 (1) should be of type empty array instead of Array.")

		context "Union type argument", ->

			it "should return an error with 'undefined or null'", ->
				f = fn [[undefined, null]], AnyType, ->
				expect( -> f(true))
				.to.throw("Argument number 1 (true) should be of type undefined or null instead of Boolean.")

			it "should return an error with 'String or Number'", ->
				f = fn [[String, Number]], AnyType, ->
				expect( -> f(true))
				.to.throw("Argument number 1 (true) should be of type String or Number instead of Boolean.")

			it "should return an error with 'literal 'foo' or literal 'bar''", ->
				f = fn [['foo', 'bar']], AnyType, ->
				expect( -> f('a'))
				.to.throw("Argument number 1 (a) should be of type
							literal String 'foo' or literal String 'bar' instead of String.")

			it "should return an error with 'literal Number '1' or literal Number '2''", ->
				f = fn [[1, 2]], AnyType, ->
				expect( -> f(3))
				.to.throw("Argument number 1 (3) should be of type
							literal Number '1' or literal Number '2' instead of Number.")

			it "should return an error with 'literal String '1' or literal Number '1'", ->
				f = fn [['1', 1]], AnyType, ->
				expect( -> f(3))
				.to.throw("Argument number 1 (3) should be of type
							literal String '1' or literal Number '1' instead of Number.")

			it "should return an error with 'literal Boolean 'true' or literal Boolean 'false'", ->
				f = fn [[true, false]], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type
							literal Boolean 'true' or literal Boolean 'false' instead of Number.")

		context "Typed Array type argument", ->

			it "should return an error with 'array of 'Number''", ->
				f = fn [Array(Number)], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type array of 'Number' instead of Number.")

			it "should return an error with 'array of 'Promise''", ->
				f = fn [Array(Promise)], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type array of 'Promise' instead of Number.")

			it "should return an error with 'array of 'String or Number''", ->
				f = fn [Array([String, Number])], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type array of 'String or Number' instead of Number.")

			it "should return an error with 'array of 'custom type object''", ->
				f = fn [Array({a: String, b: Number})], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type array of 'custom type object' instead of Number.")

			it "Array([]) should return an error with 'array of 'any type''", ->
				f = fn [Array([])], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type array of 'any type' instead of Number.")

			it "Array(AnyType)] should return an error with 'array of 'any type''", ->
				f = fn [Array(AnyType)], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type array of 'any type' instead of Number.")

			it "Array(AnyType()) should return an error with 'array of 'any type''", ->
				f = fn [Array(AnyType())], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type array of 'any type' instead of Number.")

		context "Tuple type argument", ->

			it "should return an error with 'tuple of 3 elements 'Number, Boolean, String''", ->
				f = fn [Tuple(Number, Boolean, String)], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type tuple of
							3 elements 'Number, Boolean, String' instead of Number")

			it "should return an error with 'tuple of 3 elements 'Number, Object or null, String''", ->
				f = fn [Tuple(Number, [Object, null], String)], AnyType, ->
				expect( -> f(1))
				.to.throw("Argument number 1 (1) should be of type tuple of
							3 elements 'Number, Object or null, String' instead of Number")
