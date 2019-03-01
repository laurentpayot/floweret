import sinon from 'sinon'
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
chai.use(chaiAsPromised)
expect = chai.expect

import {
	fn, isValid, typeOf,
	etc, Any, # types used anyway
	maybe, # exported because generally always used,
	object, array
} from '../src'
import {
	Type, promised, constraint, foreign,
	Integer, Natural, SizedString, Tuple, TypedObject, TypedSet, TypedMap,
	and as And, or as Or, not as Not
} from '../src/types/_index'
import {isAny, isLiteral} from '../src/tools'


NATIVE_TYPES = [undefined, null, NaN, Infinity, -Infinity,
				Boolean, Number, String, Array, Date, Object, Function, Promise, Int8Array, Set, Map, Symbol]
VALUES = [
	undefined
	null
	NaN
	1.1
	0
	Infinity
	-Infinity
	true
	false
	""
	"a"
	" "
	"Énorme !"
	[]
	[1]
	[undefined]
	Array(1)
	Array(2)
	Array(3)
	[1, 'a', null, undefined]
	new Int8Array([1, 2])
	{}
	{foo: 'bar'}
	{name: 'Number'}
	{a: 1, b: {a: 2, b: null, c: '3'}}
	new Date()
	(->)
	new Promise(->)
	new Set([])
	new Set([1, 2])
	new Map([])
	new Map([[ 1, 'one' ], [ 2, 'two' ]])
	Symbol('foo')
]

testTypes = (val, type) ->
	expect(isValid(val, type)).to.be.true
	expect(isValid(val, t)).to.be.false \
		for t in NATIVE_TYPES when not(t is type or Number.isNaN val and Number.isNaN type)

warnSpy = sinon.spy(Type.prototype, 'warn')
# Silencing console.warn by stubing it. Not restubing if testing with --watch option and tests are run again.
sinon.stub(console, "warn") unless console.warn.restore # "duck typing" stub detection


###
	████████╗██╗   ██╗██████╗ ███████╗ ██████╗ ███████╗
	╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔═══██╗██╔════╝
	   ██║    ╚████╔╝ ██████╔╝█████╗  ██║   ██║█████╗
	   ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ██║   ██║██╔══╝
	   ██║      ██║   ██║     ███████╗╚██████╔╝██║
	   ╚═╝      ╚═╝   ╚═╝     ╚══════╝ ╚═════╝ ╚═╝
###
describe "typeOf", ->

	# TODO: add more tests

	it "should return 'NaN' for NaN", ->
		expect(typeOf(NaN)).to.equal('NaN')

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

	# it "should return 'Object' for an object value even after Object.name modification", ->
	# 	Object.name = "foo"
	# 	expect(typeOf({})).to.equal('Object')

	# it "should return 'Function' for an Function value even after Function.name modification", ->
	# 	Function.name = "foo"
	# 	expect(typeOf(->)).to.equal('Function')

###
	██╗███████╗██╗     ██╗████████╗███████╗██████╗  █████╗ ██╗
	██║██╔════╝██║     ██║╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██║
	██║███████╗██║     ██║   ██║   █████╗  ██████╔╝███████║██║
	██║╚════██║██║     ██║   ██║   ██╔══╝  ██╔══██╗██╔══██║██║
	██║███████║███████╗██║   ██║   ███████╗██║  ██║██║  ██║███████╗
	╚═╝╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
###
describe "isLiteral", ->

	it "should return true for undefined", ->
		expect(isLiteral(undefined)).to.be.true

	it "should return true for null", ->
		expect(isLiteral(null)).to.be.true

	it "should return true for NaN", ->
		expect(isLiteral(NaN)).to.be.true

	it "should return true for Infinity", ->
		expect(isLiteral(Infinity)).to.be.true

	it "should return true for -Infinity", ->
		expect(isLiteral(-Infinity)).to.be.true

	it "should return true for 0", ->
		expect(isLiteral(0)).to.be.true

	it "should return true for a number", ->
		expect(isLiteral(100)).to.be.true
		expect(isLiteral(-100)).to.be.true
		expect(isLiteral(100.1234)).to.be.true

	it "should return true for empty string", ->
		expect(isLiteral('')).to.be.true

	it "should return true for strings", ->
		expect(isLiteral(val)).to.be.true for val in VALUES when typeof val is 'string'

	it "should return true for booleans", ->
		expect(isLiteral(true)).to.be.true
		expect(isLiteral(false)).to.be.true

###
	██╗███████╗ █████╗ ███╗   ██╗██╗   ██╗
	██║██╔════╝██╔══██╗████╗  ██║╚██╗ ██╔╝
	██║███████╗███████║██╔██╗ ██║ ╚████╔╝
	██║╚════██║██╔══██║██║╚██╗██║  ╚██╔╝
	██║███████║██║  ██║██║ ╚████║   ██║
	╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝
###
describe "isAny", ->

	it "should return false for native types", ->
		expect(isAny(t)).to.be.false for t in NATIVE_TYPES

	it "should return true for Any", ->
		expect(isAny(Any)).to.be.true

	it "should return true for Any()", ->
		expect(isAny(Any())).to.be.true

###
	██╗███████╗██╗   ██╗ █████╗ ██╗     ██╗██████╗
	██║██╔════╝██║   ██║██╔══██╗██║     ██║██╔══██╗
	██║███████╗██║   ██║███████║██║     ██║██║  ██║
	██║╚════██║╚██╗ ██╔╝██╔══██║██║     ██║██║  ██║
	██║███████║ ╚████╔╝ ██║  ██║███████╗██║██████╔╝
	╚═╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝╚═════╝
###
describe "isValid", ->

	context "Special Types", ->

		context "Empty array", ->

			it "should return true for empty array only", ->
				expect(isValid([], [])).to.be.true
				expect(isValid(v, [])).to.be.false for v in VALUES when not (Array.isArray(v) and not v.length)

		context "Empty object", ->

			it "should return true for empty object only", ->
				expect(isValid({}, {})).to.be.true
				expect(isValid(v, {})).to.be.false for v in VALUES \
					when not (v?.constructor is Object and not Object.keys(v).length)

		context "Any type", ->

			it "Any type should return true for all values", ->
				expect(isValid(val, Any)).to.be.true for val in VALUES

			it "Any() type should return true for all values", ->
				expect(isValid(val, Any())).to.be.true for val in VALUES

			it "Any(Number) type should throw an error", ->
				expect(-> isValid(1, Any(Number))).to.throw("'Any' cannot have any arguments.")

			it "Any([]) type should throw an error", ->
				expect(-> isValid(1, Any([]))).to.throw("'Any' cannot have any arguments.")

		context "Maybe type", ->

			it "maybe(Any) should not return Any type.", ->
				warnSpy.resetHistory()
				expect(maybe(Any)).to.eql([undefined, Any])
				expect(warnSpy.calledOnceWithExactly(
					"Any is not needed as 'maybe' argument."
				)).to.be.true

			it "maybe(Any()) should not return Any type.", ->
				warnSpy.resetHistory()
				expect(maybe(Any())).to.eql([undefined, Any()])
				expect(warnSpy.calledOnceWithExactly(
					"Any is not needed as 'maybe' argument."
				)).to.be.true

			it "maybe should throw an error when used as with more than 1 argument", ->
				expect(-> isValid(1, maybe(Number, String)))
				.to.throw("'maybe' must have exactly 1 argument.")

			it "maybe(undefined) should throw an error", ->
				expect(-> isValid(1, maybe(undefined)))
				.to.throw("'maybe' argument cannot be undefined.")

			it "should return true when value is undefined.", ->
				expect(isValid(undefined, maybe(t))).to.be.true for t in NATIVE_TYPES when t isnt undefined

			it "should return true for a null type, false for other types.", ->
				expect(isValid(null, maybe(null))).to.be.true
				expect(isValid(null, maybe(t))).to.be.false for t in NATIVE_TYPES when t isnt undefined and t isnt null

			it "should return true for a number type, false for other types.", ->
				expect(isValid(1.1, maybe(Number))).to.be.true
				expect(isValid(1.1, maybe(t))).to.be.false for t in NATIVE_TYPES when t isnt undefined and t isnt Number

			it "should return true for a string type, false for other types.", ->
				expect(isValid("Énorme !", maybe(String))).to.be.true
				expect(isValid("Énorme !", maybe(t))).to.be.false for t in NATIVE_TYPES when t isnt undefined and t isnt String

			it "should return true for a Number or a String or undefined, when union is used", ->
				expect(isValid(1, maybe([Number, String]))).to.be.true
				expect(isValid('1', maybe([Number, String]))).to.be.true
				expect(isValid(undefined, maybe([Number, String]))).to.be.true

			it "maybe() should throw an error when type is ommited", ->
				expect(-> isValid(1, maybe()))
				.to.be.throw("'maybe' must have exactly 1 argument.")

			it "maybe should throw an error when used as a function", ->
				expect(-> isValid(1, maybe)).to.throw("'maybe' must have exactly 1 argument")

	context "Literal Types", ->

		it "should return true when value is the same string as the type literal, false if different", ->
			expect(isValid("foo", "foo")).to.be.true
			expect(isValid("Énorme !", "Énorme !")).to.be.true
			expect(isValid('', '')).to.be.true
			expect(isValid(' ', ' ')).to.be.true
			expect(isValid("Foo", "foo")).to.be.false
			expect(isValid("string", "foo")).to.be.false
			expect(isValid("String", "foo")).to.be.false
			expect(isValid(String, "String")).to.be.false

		it "should return true when value is the same number as the type literal, false if different", ->
			expect(isValid(1234, 1234)).to.be.true
			expect(isValid(1234.56, 1234.56)).to.be.true
			expect(isValid(-1, -1)).to.be.true
			expect(isValid(1235, 1234)).to.be.false
			expect(isValid(-1234, 1234)).to.be.false
			expect(isValid(Number, 1234)).to.be.false

		it "should return true when value is the same boolean as the type literal, false if different", ->
			expect(isValid(true, true)).to.be.true
			expect(isValid(false, true)).to.be.false
			expect(isValid(false, false)).to.be.true
			expect(isValid(true, false)).to.be.false
			expect(isValid(Boolean, true)).to.be.false
			expect(isValid(Boolean, false)).to.be.false

	context "Native Types", ->

		it "should return true for an undefined type, false for other types", ->
			testTypes(undefined, undefined)

		it "should return true for a null type, false for other types", ->
			testTypes(null, null)

		it "should return true for NaN type, false for other types", ->
			expect(isValid(NaN, NaN)).to.be.true
			expect(isValid(NaN, Number)).to.be.false
			expect(isValid(1, NaN)).to.be.false
			testTypes(NaN, NaN)

		it "should return true for Infinity type, false for other types", ->
			expect(isValid(Infinity, Infinity)).to.be.true
			expect(isValid(Infinity, Number)).to.be.false
			expect(isValid(1, Infinity)).to.be.false
			testTypes(Infinity, Infinity)

		it "should return true for -Infinity type, false for other types", ->
			expect(isValid(-Infinity, -Infinity)).to.be.true
			expect(isValid(-Infinity, Number)).to.be.false
			expect(isValid(-1, -Infinity)).to.be.false
			testTypes(-Infinity, -Infinity)

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
			expect(isValid({}, {})).to.be.true

		it "should return false if type is empty object but value unempty object.", ->
			expect(isValid({a: 1}, {})).to.be.false

		it "should return false if value is empty object but type unempty object.", ->
			expect(isValid({}, {a: Number})).to.be.false

		it "should return true if same object type but one more key.", ->
			expect(isValid({a: 1, b: 2, c: 'foo'}, {a: Number, b: Number})).to.be.true

		it "should return false if same object type but one key less.", ->
			expect(isValid({a: 1}, {a: Number, b: Number})).to.be.false

		it "should return false for an object type and non object values", ->
			UserType =
				id: Number
				name: String
			expect(isValid(undefined, UserType)).to.be.false
			expect(isValid(null, UserType)).to.be.false
			expect(isValid(val, UserType)).to.be.false \
				for val in VALUES when val isnt undefined and val isnt null and val.constructor isnt Object

		it "should return true for a shallow object type, false otherwise", ->
			UserType =
				id: Number
				name: String
			expect(isValid({id: 1234, name: "Smith"}, UserType)).to.be.true
			expect(isValid({id: 1234, name: "Smith", foo: "bar"}, UserType)).to.be.true
			expect(isValid({foo: 1234, name: "Smith"}, UserType)).to.be.false
			expect(isValid({id: '1234', name: "Smith"}, UserType)).to.be.false
			expect(isValid({id: 1234, name: ["Smith"]}, UserType)).to.be.false
			expect(isValid({name: "Smith"}, UserType)).to.be.false
			expect(isValid({id: 1234}, UserType)).to.be.false
			expect(isValid({}, UserType)).to.be.false

		it "should return true for a deep object type, false otherwise", ->
			UserType =
				id: Number
				name:
					firstName: String
					lastName: String
					middleName: [String, undefined]
			expect(isValid({id: 1234, name: {firstName: "John", lastName: "Smith", middleName: "Jack"}}, UserType))
			.to.be.true
			expect(isValid({id: 1234, name: {firstName: "John", lastName: "Smith", middleName: 1}}, UserType))
			.to.be.false
			expect(isValid({id: 1234, name: {firstName: "John", lastName: "Smith"}}, UserType)).to.be.true
			expect(isValid({id: 1234}, UserType)).to.be.false
			expect(isValid({name: {firstName: "John", lastName: "Smith"}}, UserType)).to.be.false
			expect(isValid({id: 1234, name: {firstName: "John"}}, UserType)).to.be.false
			expect(isValid({id: 1234, name: {firstName: "John", lostName: "Smith"}}, UserType)).to.be.false
			expect(isValid({id: 1234, name: {firstName: "John", lastName: [1]}}, UserType)).to.be.false
			expect(isValid({id: '1234', name: "Smith"}, UserType)).to.be.false
			expect(isValid({id: 1234, name: ["Smith"]}, UserType)).to.be.false

		it "should return false for object type {name: 'Number'} and a number value", ->
			expect(isValid(1, {name: 'Number'})).to.be.false

	context "Sized Array", ->

		it "should return false for empty array", ->
			expect(isValid([], Array(1))).to.be.false
			expect(isValid([], Array(2))).to.be.false
			expect(isValid([], Array(3))).to.be.false

		it "should return true for same size array of undefined", ->
			expect(isValid([undefined], Array(1))).to.be.true
			expect(isValid([undefined, undefined], Array(2))).to.be.true
			expect(isValid([undefined, undefined, undefined], Array(3))).to.be.true

		it "should return true for same size array of anything", ->
			expect(isValid([1], Array(1))).to.be.true
			expect(isValid([1, true], Array(2))).to.be.true
			expect(isValid([undefined, true], Array(2))).to.be.true
			expect(isValid([1, true, "three"], Array(3))).to.be.true
			expect(isValid([1, true, "tree"], Array(3))).to.be.true
			expect(isValid([undefined, true, "tree"], Array(3))).to.be.true
			expect(isValid([1, undefined, "tree"], Array(3))).to.be.true

		it "should return false for different size array of anything", ->
			expect(isValid([1], Array(2))).to.be.false
			expect(isValid([1, true], Array(3))).to.be.false
			expect(isValid([1, 1], Array(3))).to.be.false
			expect(isValid([undefined, true], Array(4))).to.be.false
			expect(isValid([1, 1, 1], Array(4))).to.be.false
			expect(isValid([1, true, "three"], Array(4))).to.be.false
			expect(isValid([1, true, "tree"], Array(4))).to.be.false
			expect(isValid([undefined, true, "tree"], Array(4))).to.be.false
			expect(isValid([1, undefined, "tree"], Array(4))).to.be.false

	context "Union Types", ->

		it "should return true if the value is one of the given strings, false otherwise", ->
			expect(isValid("foo", ["foo", "bar"])).to.be.true
			expect(isValid("bar", ["foo", "bar"])).to.be.true
			expect(isValid("baz", ["foo", "bar"])).to.be.false
			expect(isValid(Array, ["foo", "bar"])).to.be.false

		it "should return true if the value is one of the given strings, false otherwise", ->
			expect(isValid(1, [1, 2])).to.be.true
			expect(isValid(2, [1, 2])).to.be.true
			expect(isValid(3, [1, 2])).to.be.false
			expect(isValid(Array, [1, 2])).to.be.false

		it "should return true for a string or a number value, false otherwise", ->
			expect(isValid("foo", [String, Number])).to.be.true
			expect(isValid(1234, [String, Number])).to.be.true
			expect(isValid(null, [String, Number])).to.be.false
			expect(isValid({}, [String, Number])).to.be.false
			expect(isValid(new Date(), [Object, Number])).to.be.false

		it "should return true for a string or null value, false otherwise", ->
			expect(isValid("foo", [String, null])).to.be.true
			expect(isValid(null, [String, null])).to.be.true
			expect(isValid(1234, [String, null])).to.be.false

		it "should return true for an object or null value, false otherwise", ->
			expect(isValid({id: 1234, name: "Smith"}, [Object, null])).to.be.true
			expect(isValid(null, [Object, null])).to.be.true
			expect(isValid("foo", [Object, null])).to.be.false

		it "should return true for an object type or null value, false otherwise", ->
			UserType =
				id: Number
				name: String
			expect(isValid({id: 1234, name: "Smith"}, [UserType, null])).to.be.true
			expect(isValid(null, [UserType, null])).to.be.true
			expect(isValid("foo", [UserType, null])).to.be.false

	context "Custom types", ->

		it "should throw an error when creating an instance of Type", ->
			expect(-> new Type()).to.throw("Abstract class 'Type' cannot be instantiated directly.")

		context "Integer type", ->

			it "should throw an error when Integer arguments are not numers", ->
				expect(-> isValid(1, Integer('100'))).to.throw("'Integer' arguments must be numbers.")
				expect(-> isValid(1, Integer(1, '100'))).to.throw("'Integer' arguments must be numbers.")
				expect(-> isValid(1, Integer('1', 100))).to.throw("'Integer' arguments must be numbers.")
				expect(-> isValid(1, Integer('1', '100'))).to.throw("'Integer' arguments must be numbers.")

			it "should not throw an error when Integer is used as a function", ->
				expect(isValid(1, Integer)).to.be.true

			it "should not throw an error when Integer is used without arguments", ->
				expect(isValid(1, Integer())).to.be.true

			it "should return true for an integer number", ->
				expect(isValid(1, Integer)).to.be.true
				expect(isValid(0, Integer)).to.be.true
				expect(isValid(-0, Integer)).to.be.true
				expect(isValid(-1, Integer)).to.be.true

			it "should return false for an decimal number", ->
				expect(isValid(1.1, Integer)).to.be.false
				expect(isValid(0.1, Integer)).to.be.false
				expect(isValid(-0.1, Integer)).to.be.false
				expect(isValid(-1.1, Integer)).to.be.false

		context "Natural type", ->

			it "should throw an error when Natural arguments are not numers", ->
				expect(-> isValid(1, Natural('100')))
				.to.throw("'Natural' arguments must be numbers.")

			it "should throw an error when Natural arguments are negative", ->
				expect(-> isValid(1, Natural(-1)))
				.to.throw("'Natural' arguments must be positive numbers.")

			it "should throw an error when Natural arguments are negative", ->
				expect(-> isValid(1, Natural(-100, -10)))
				.to.throw("'Natural' arguments must be positive numbers.")

			it "should return false for an negative integer", ->
				expect(isValid(-1, Natural)).to.be.false

			it "should return true for an positive integer", ->
				expect(isValid(1, Natural)).to.be.true

			it "should return true for zero", ->
				expect(isValid(0, Natural)).to.be.true
				expect(isValid(-0, Natural)).to.be.true

		context "SizedString type", ->

			it "should throw an error when SizedString is used as a function", ->
				expect(-> isValid("123", SizedString)).to.throw("'SizedString' must have at least 1 argument.")

			it "should throw an error when SizedString is used without arguments", ->
				expect(-> isValid("123", SizedString())).to.throw("'SizedString' must have at least 1 argument.")

			it "should throw an error when SizedString arguments are not numers", ->
				expect(-> isValid("123", SizedString('100')))
				.to.throw("'SizedString' arguments must be positive integers.")

			it "should throw an error when SizedString arguments are negative", ->
				expect(-> isValid("123", SizedString(-1)))
				.to.throw("'SizedString' arguments must be positive integers.")

			it "should throw an error when SizedString arguments are negative", ->
				expect(-> isValid("123", SizedString(-100, -10)))
				.to.throw("'SizedString' arguments must be positive integers.")

			it "should return false for a too long string", ->
				expect(isValid("123", SizedString(2))).to.be.false

			it "should return false for a too short string", ->
				expect(isValid("123", SizedString(4, 10))).to.be.false

		context "Tuple type", ->

			it "should throw an error when Tuple is used as a function", ->
				expect(-> isValid(1, Tuple)).to.throw("'Tuple' must have at least 2 arguments.")

			it "should throw an error when Tuple is used without arguments", ->
				expect(-> isValid(1, Tuple())).to.throw("'Tuple' must have at least 2 arguments.")

			context "Any type elements", ->

				it "Tuple of Any should return array of empty elements", ->
					warnSpy.resetHistory()
					t = Tuple(Any, Any)
					expect(t.constructor.name).to.equal("Tuple")
					expect(t.types).to.eql([Any, Any])
					expect(warnSpy.calledOnceWithExactly(
						"Use 'Array(2)' type instead of a Tuple of 2 values of any type'."
					)).to.be.true

				it "Tuple of Any() should return array of empty elements", ->
					warnSpy.resetHistory()
					t = Tuple(Any(), Any())
					expect(t.constructor.name).to.equal("Tuple")
					expect(t.types).to.eql([Any(), Any()])
					expect(warnSpy.calledOnceWithExactly(
						"Use 'Array(2)' type instead of a Tuple of 2 values of any type'."
					)).to.be.true


			context "Native type elements", ->

				it "should return true when value is an array correspondig to Tuple type", ->
					expect(isValid([1, true, "three"], Tuple(Number, Boolean, String))).to.be.true

				it "should return false when value is an array not correspondig to Tuple type", ->
					expect(isValid(["1", true, "three"], Tuple(Number, Boolean, String))).to.be.false

				it "should return false when value is a number", ->
					expect(isValid(1, Tuple(Number, Boolean, String))).to.be.false

				it "should return false when value is an empty array", ->
					expect(isValid([], Tuple(Number, Boolean, String))).to.be.false

		context "Typed object", ->

			it "should throw an error when TypedObject is used as a function", ->
				expect(-> isValid(1, TypedObject)).to.throw("'TypedObject' must have exactly 1 argument.")

			it "should throw an error when TypedObject is used without arguments", ->
				expect(-> isValid(1, TypedObject())).to.throw("'TypedObject' must have exactly 1 argument.")

		context "Typed array", ->

			context "Native type elements", ->

				it "should return false when value is not an array", ->
					expect(isValid(val, Array(Number))).to.be.false for val in VALUES when not Array.isArray(val)
					expect(isValid(val, Array(String))).to.be.false for val in VALUES when not Array.isArray(val)

				it "should return true for an array of numbers", ->
					expect(isValid([1, 2, 3], Array(Number))).to.be.true
					expect(isValid([1], Array(Number))).to.be.true
					expect(isValid([], Array(Number))).to.be.true

				it "should return true for an array of strings", ->
					expect(isValid(["foo", "bar", "baz"], Array(String))).to.be.true
					expect(isValid(["foo"], Array(String))).to.be.true
					expect(isValid([], Array(String))).to.be.true

				it "should return false when an element of the array is not a number", ->
					expect(isValid([1, val, 3], Array(Number))).to.be.false for val in VALUES when typeof val isnt 'number'
					expect(isValid([val], Array(Number))).to.be.false for val in VALUES when typeof val isnt 'number'

				# TODO: test typed array optimizations

				it "should return false when an element of the array is not a string", ->
					expect(isValid(["foo", val, "bar"], Array(String))).to.be.false \
						for val in VALUES when typeof val isnt 'string'
					expect(isValid([val], Array(String))).to.be.false \
						for val in VALUES when typeof val isnt 'string'

			context "Object type elements", ->

				it "should return false when value is not an array", ->
					nsType = {n: Number, s: String}
					expect(isValid(val, Array(nsType))).to.be.false for val in VALUES when not Array.isArray(val)

				it "should return true when all elements of the array are of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isValid([{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}], Array(nsType))).to.be.true
					expect(isValid([{n: 1, s: "a"}], Array(nsType))).to.be.true
					expect(isValid([], Array(nsType))).to.be.true

				it "should return false when some elements of the array are not of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isValid([{n: 1, s: "a"}, val, {n: 3, s: "c"}], Array(nsType))).to.be.false for val in VALUES
					expect(isValid([val], Array(nsType))).to.be.false for val in VALUES
					expect(isValid([{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}], Array(nsType))).to.be.false

			context "Union type elements", ->

				it "should return false when value is not an array", ->
					expect(isValid(val, Array([Number, String]))).to.be.false for val in VALUES when not Array.isArray(val)

				it "should return true for an array whom values are strings or numbers", ->
					expect(isValid([], Array([String, Number]))).to.be.true
					expect(isValid(["foo", "bar", "baz"], Array([String, Number]))).to.be.true
					expect(isValid(["foo"], Array([String, Number]))).to.be.true
					expect(isValid([1, 2, 3], Array([String, Number]))).to.be.true
					expect(isValid([1], Array([String, Number]))).to.be.true
					expect(isValid(["foo", 1, "bar"], Array([String, Number]))).to.be.true
					expect(isValid([1, "foo", 2], Array([String, Number]))).to.be.true

				it "should return false when an element of the array is not a string nor a number", ->
					expect(isValid(["foo", val, 1], Array([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
					expect(isValid([val], Array([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'

		context "Typed set", ->

			context "Literal type elements", ->

				it "should throw an error when type is literal", ->
					expect(-> TypedSet(1)).to.throw("You cannot have literal Number 1 as 'TypedSet' argument.")
					expect(-> TypedSet(undefined)).to.throw("You cannot have undefined as 'TypedSet' argument.")
					expect(-> TypedSet(null)).to.throw("You cannot have null as 'TypedSet' argument.")

			context "Any type elements", ->

				it "TypedSet() should throw an error", ->
					expect(-> TypedSet()).to.throw("'TypedSet' must have exactly 1 argument.")

				it "TypedSet used as a function should throw an error.", ->
					expect(-> isValid(1, TypedSet)).to.throw("'TypedSet' must have exactly 1 argument.")

				it "TypedSet(Any) should return a TypedSet instance and log a warning.", ->
					warnSpy.resetHistory()
					t = TypedSet(Any)
					expect(t.constructor.name).to.equal("TypedSet")
					expect(t.type).to.eql(Any)
					expect(warnSpy.calledOnceWithExactly(
						"Use 'Set' type instead of a TypedSet with elements of any type."
					)).to.be.true

				it "TypedSet(Any()) should return a TypedSet instance and log a warning.", ->
					warnSpy.resetHistory()
					t = TypedSet(Any())
					expect(t.constructor.name).to.equal("TypedSet")
					expect(t.type).to.eql(Any())
					expect(warnSpy.calledOnceWithExactly(
						"Use 'Set' type instead of a TypedSet with elements of any type."
					)).to.be.true

			context "Native type elements", ->

				it "should return false when value is not a set", ->
					expect(isValid(val, TypedSet(Number))).to.be.false for val in VALUES when not val?.constructor is Set
					expect(isValid(val, TypedSet(String))).to.be.false for val in VALUES when not val?.constructor is Set

				it "should return true for a set of numbers", ->
					expect(isValid(new Set([1, 2, 3]), TypedSet(Number))).to.be.true
					expect(isValid(new Set([1]), TypedSet(Number))).to.be.true
					expect(isValid(new Set([]), TypedSet(Number))).to.be.true

				it "should return true for a set of strings", ->
					expect(isValid(new Set(["foo", "bar", "baz"]), TypedSet(String))).to.be.true
					expect(isValid(new Set(["foo"]), TypedSet(String))).to.be.true
					expect(isValid(new Set([]), TypedSet(String))).to.be.true

				it "should return false when an element of the set is not a number", ->
					expect(isValid(new Set([1, val, 3]), TypedSet(Number))).to.be.false for val in VALUES when typeof val isnt 'number'
					expect(isValid(new Set([val]), TypedSet(Number))).to.be.false for val in VALUES when typeof val isnt 'number'

				it "should return false when an element of the set is not a string", ->
					expect(isValid(new Set(["foo", val, "bar"]), TypedSet(String))).to.be.false \
						for val in VALUES when typeof val isnt 'string'
					expect(isValid(new Set([val]), TypedSet(String))).to.be.false \
						for val in VALUES when typeof val isnt 'string'

			context "Object type elements", ->

				it "should return false when value is not a set", ->
					nsType = {n: Number, s: String}
					expect(isValid(val, TypedSet(nsType))).to.be.false for val in VALUES when not val?.constructor is Set

				it "should return true when all elements of the set are of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isValid(new Set([{n: 1, s: "a"}, {n: 2, s: "b"}, {n: 3, s: "c"}]), TypedSet(nsType))).to.be.true
					expect(isValid(new Set([{n: 1, s: "a"}]), TypedSet(nsType))).to.be.true
					expect(isValid(new Set([]), TypedSet(nsType))).to.be.true

				it "should return false when some elements of the set are not of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isValid(new Set([{n: 1, s: "a"}, val, {n: 3, s: "c"}]), TypedSet(nsType))).to.be.false for val in VALUES
					expect(isValid(new Set([val]), TypedSet(nsType))).to.be.false for val in VALUES
					expect(isValid(new Set([{n: 1, s: "a"}, {foo: 2, s: "b"}, {n: 3, s: "c"}]), TypedSet(nsType))).to.be.false

			context "Union type elements", ->

				it "should return false when value is not a set", ->
					expect(isValid(val, TypedSet([Number, String]))).to.be.false for val in VALUES when not val?.constructor is Set

				it "should return true for a set whom values are strings or numbers", ->
					expect(isValid(new Set([]), TypedSet([String, Number]))).to.be.true
					expect(isValid(new Set(["foo", "bar", "baz"]), TypedSet([String, Number]))).to.be.true
					expect(isValid(new Set(["foo"]), TypedSet([String, Number]))).to.be.true
					expect(isValid(new Set([1, 2, 3]), TypedSet([String, Number]))).to.be.true
					expect(isValid(new Set([1]), TypedSet([String, Number]))).to.be.true
					expect(isValid(new Set(["foo", 1, "bar"]), TypedSet([String, Number]))).to.be.true
					expect(isValid(new Set([1, "foo", 2]), TypedSet([String, Number]))).to.be.true

				it "should return false when an element of the set is not a string nor a number", ->
					expect(isValid(new Set(["foo", val, 1]), TypedSet([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
					expect(isValid(new Set([val]), TypedSet([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'

		context "Typed map", ->

			context "Literal type elements", ->

				it "should throw an error when literals for both keys and values types", ->
					expect(-> TypedMap("foo", 1))
					.to.throw("You cannot have both literal String \"foo\" as keys type
								and literal Number 1 as values type in a TypedMap.")
					expect(-> TypedMap(null, undefined))
					.to.throw("You cannot have both null as keys type and undefined as values type in a TypedMap.")
					expect(-> TypedMap(undefined, undefined))
					.to.throw("You cannot have both undefined as keys type and undefined as values type in a TypedMap.")

			context "Any type elements", ->

				it "TypedMap() should throw an error.", ->
					expect(-> TypedMap()).to.throw("'TypedMap' must have at least 1 argument.")

				it "TypedMap used as a function should throw an error.", ->
					expect(-> isValid(1, TypedMap)).to.throw("'TypedMap' must have at least 1 argument.")

				it "TypedMap(Any) should return a TypedMap instance and log a warning.", ->
					warnSpy.resetHistory()
					t = TypedMap(Any)
					expect(t.constructor.name).to.equal("TypedMap")
					expect(t.valuesType).to.eql(Any)
					expect(warnSpy.calledOnceWithExactly(
						"Use 'Map' type instead of a TypedMap with values of any type."
					)).to.be.true

				it "TypedMap(Any, Any) should return a TypedMap instance and log a warning.", ->
					warnSpy.resetHistory()
					t = TypedMap(Any, Any)
					expect(t.constructor.name).to.equal("TypedMap")
					expect([t.valuesType, t.keysType]).to.eql([Any, Any])
					expect(warnSpy.calledOnceWithExactly(
						"Use 'Map' type instead of a TypedMap with keys and values of any type."
					)).to.be.true

				it "TypedMap(Any()) should return a TypedMap instance and log a warning.", ->
					warnSpy.resetHistory()
					t = TypedMap(Any())
					expect(t.constructor.name).to.equal("TypedMap")
					expect(t.valuesType).to.eql(Any())
					expect(warnSpy.calledOnceWithExactly(
						"Use 'Map' type instead of a TypedMap with values of any type."
					)).to.be.true

				it "TypedMap(Any(), Any()) should return a TypedMap instance and log a warning.", ->
					warnSpy.resetHistory()
					t = TypedMap(Any(), Any())
					expect(t.constructor.name).to.equal("TypedMap")
					expect([t.valuesType, t.keysType]).to.eql([Any(), Any()])
					expect(warnSpy.calledOnceWithExactly(
						"Use 'Map' type instead of a TypedMap with keys and values of any type."
					)).to.be.true

			context "Native type elements", ->

				it "should return false when value is not a Map", ->
					expect(isValid(val, TypedMap(Number))).to.be.false for val in VALUES when not val?.constructor is Map
					expect(isValid(val, TypedMap(String))).to.be.false for val in VALUES when not val?.constructor is Map
					expect(isValid(val, TypedMap(Number, String))).to.be.false for val in VALUES when not val?.constructor is Map
					expect(isValid(val, TypedMap(String, Number))).to.be.false for val in VALUES when not val?.constructor is Map

				it "should return true for a Map of numbers", ->
					expect(isValid(new Map([['one', 1], ['two', 2], ['three', 3]]), TypedMap(Number))).to.be.true
					expect(isValid(new Map([['one', 1]]), TypedMap(Number))).to.be.true
					expect(isValid(new Map([]), TypedMap(Number))).to.be.true

				it "should return true for a Map of strings -> numbers", ->
					expect(isValid(new Map([['one', 1], ['two', 2], ['three', 3]]), TypedMap(String, Number))).to.be.true
					expect(isValid(new Map([['one', 1]]), TypedMap(String, Number))).to.be.true
					expect(isValid(new Map([]), TypedMap(String, Number))).to.be.true

				it "should return true for a Map of strings", ->
					expect(isValid(new Map([[1, 'one'], [2, 'two'], [3, 'three']]), TypedMap(String))).to.be.true
					expect(isValid(new Map([[1, 'one']]), TypedMap(String))).to.be.true
					expect(isValid(new Map([]), TypedMap(String))).to.be.true

				it "should return true for a Map of numbers -> strings", ->
					expect(isValid(new Map([[1, 'one'], [2, 'two'], [3, 'three']]), TypedMap(Number, String))).to.be.true
					expect(isValid(new Map([[1, 'one']]), TypedMap(Number, String))).to.be.true
					expect(isValid(new Map([]), TypedMap(Number, String))).to.be.true

				it "should return false when an element of the Map is not a number", ->
					expect(isValid(new Map([['one', 1], ['two', val], ['three', 3]]), TypedMap(Number)))
					.to.be.false for val in VALUES when typeof val isnt 'number'
					expect(isValid(new Map([['foo', val]]), TypedMap(Number)))
					.to.be.false for val in VALUES when typeof val isnt 'number'

				it "should return false when an element of the Map is not a string", ->
					expect(isValid(new Map([[1, 'one'], [2, val], [3, 'three']]), TypedMap(String)))
					.to.be.false for val in VALUES when typeof val isnt 'string'
					expect(isValid(new Map([[1234, val]]), TypedMap(String)))
					.to.be.false for val in VALUES when typeof val isnt 'string'

				it "should return false when a value of the Map number -> string is not a string", ->
					expect(isValid(new Map([[1, 'one'], [2, val], [3, 'three']]), TypedMap(Number, String)))
					.to.be.false for val in VALUES when typeof val isnt 'string'
					expect(isValid(new Map([[1234, val]]), TypedMap(Number, String)))
					.to.be.false for val in VALUES when typeof val isnt 'string'

				it "should return false when a key of the Map number -> string is not a string", ->
					expect(isValid(new Map([[1, 'one'], [val, 'two'], [3, 'three']]), TypedMap(Number, String)))
					.to.be.false for val in VALUES when typeof val isnt 'number'
					expect(isValid(new Map([[val, 'foo']]), TypedMap(Number, String)))
					.to.be.false for val in VALUES when typeof val isnt 'number'

			context "Object type elements", ->

				it "should return false when value is not a Map", ->
					nsType = {n: Number, s: String}
					expect(isValid(val, TypedMap(nsType))).to.be.false for val in VALUES when not val?.constructor is Map

				it "should return true when all elements of the Map are of a given object type", ->
					nsType = {n: Number, s: String}
					m = new Map([[1, {n: 1, s: "a"}], [2, {n: 2, s: "b"}], [3, {n: 3, s: "c"}]])
					expect(isValid(m, TypedMap(nsType))).to.be.true
					expect(isValid(new Map([[1, {n: 1, s: "a"}]]), TypedMap(nsType))).to.be.true
					expect(isValid(new Map([]), TypedMap(nsType))).to.be.true

				it "should return false when some elements of the Map are not of a given object type", ->
					nsType = {n: Number, s: String}
					expect(isValid(new Map([[1, {n: 1, s: "a"}], [2, val], [3, {n: 3, s: "c"}]]),
									TypedMap(nsType))).to.be.false for val in VALUES
					expect(isValid(new Map([[1, val]]), TypedMap(nsType))).to.be.false for val in VALUES
					expect(isValid(new Map([[1, {n: 1, s: "a"}], [2, {foo: 2, s: "b"}], [3, {n: 3, s: "c"}]]),
									TypedMap(nsType))).to.be.false

			context "Union type elements", ->

				it "should return false when value is not a Map", ->
					expect(isValid(val, TypedMap([Number, String]))).to.be.false for val in VALUES when not val?.constructor is Map

				it "should return true for a Map whom values are strings or numbers", ->
					expect(isValid(new Map([]), TypedMap([String, Number]))).to.be.true
					expect(isValid(new Map([[1, "foo"], [2, "bar"], [3, "baz"]]), TypedMap([String, Number]))).to.be.true
					expect(isValid(new Map([[1, "foo"]]), TypedMap([String, Number]))).to.be.true
					expect(isValid(new Map([[1, 1], [2, 2], [3, 3]]), TypedMap([String, Number]))).to.be.true
					expect(isValid(new Map([[1, 1]]), TypedMap([String, Number]))).to.be.true
					expect(isValid(new Map([[1, "foo"], [2, 1], [3, "bar"]]), TypedMap([String, Number]))).to.be.true
					expect(isValid(new Map([[1, "foo"], [2, 2]]), TypedMap([String, Number]))).to.be.true

				it "should return false when an element of the Map is not a string nor a number", ->
					expect(isValid(new Map([[1, "foo"], [2, val], [3, 1]]), TypedMap([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'
					expect(isValid(new Map([[1, val]]), TypedMap([String, Number]))).to.be.false \
						for val in VALUES when typeof val isnt 'string' and typeof val isnt 'number'

	context "Foreign Type", ->

		it "should return true when value is an instance of the foreign constructor", ->
			class Foo extends String
			foo = new Foo('foo')
			expect(isValid(foo, foreign('Foo'))).to.be.true

		it "should return false when value is not an instance of the foreign constructor", ->
			class Foo extends String
			foo = new Foo('foo')
			expect(isValid(foo, foreign('Bar'))).to.be.false
			expect(isValid('baz', foreign('Foo'))).to.be.false

		it "should return true when value has the same property types", ->
			class Foo extends String
				bar: true
				baz: 0
			foo = new Foo('foo')
			expect(isValid(foo, foreign({bar: Boolean}))).to.be.true
			expect(isValid(foo, foreign({bar: Boolean, baz: Number}))).to.be.true
			expect(isValid(foo, foreign({bar: Boolean, baz: Number, boo: undefined}))).to.be.true

		it "should return false when value has not the same property types", ->
			class Foo extends String
				bar: true
				baz: 0
			foo = new Foo('foo')
			expect(isValid(foo, foreign({bar: Boolean, baz: String}))).to.be.false
			expect(isValid(foo, foreign({bar: Boolean, baz: Number, boo: String}))).to.be.false
			expect(isValid(foo, foreign({bar: Boolean, baz: Number, boo: String}))).to.be.false

	context "Promised type", ->

		it "should throw an error for a promised number.", ->
			expect(-> isValid(Promise.resolve(1), Promise.resolve(Number)))
			.to.throw("Type can not be an instance of Promise. Use Promise as type instead.")
			expect(-> isValid(Promise.resolve(1), promised(Number)))
			.to.throw("Type can not be an instance of Promise. Use Promise as type instead.")

	context "Custom type (class)", ->

		it "should return true when type is MyClass, false for other types", ->
			class MyClass
			mc = new MyClass
			testTypes(mc, MyClass)

	context "Unmanaged Types", ->

		it "should throw an error when etc is used as a function", ->
			expect(-> isValid(1, etc))
			.to.throw("'etc' cannot be used in types.")

		it "should throw an error when etc is used without parameter", ->
			expect(-> isValid(1, etc()))
			.to.throw("'etc' cannot be used in types.")

		it "should throw an error when type is not a native type nor an object nor an array of types
			nor a string or number or boolean literal.", ->
			expect(-> isValid(val, Symbol("foo")))
			.to.throw("Type can not be an instance of Symbol. Use Symbol as type instead.") for val in VALUES

	context "Logical operators", ->

		context "And", ->

			it "And with a single value should throw an error", ->
				expect(-> And(1)).to.throw("'and' must have at least 2 arguments.")

			it "And with Any values should return an And instance and log a warning.", ->
				warnSpy.resetHistory()
				t = And(Number, Any)
				expect(t.constructor.name).to.equal("And")
				expect(t.types).to.eql([Number, Any])
				expect(warnSpy.calledOnceWithExactly(
					"Any is not needed as 'and' argument number 2."
				)).to.be.true

			it "And with undefined value should throw an error.", ->
				expect(-> And(Number, undefined)).to.throw("You cannot have undefined as 'and' argument number 2.")
				expect(-> And(undefined, Number)).to.throw("You cannot have undefined as 'and' argument number 1.")

			it "And with null value should throw an error.", ->
				expect(-> And(Number, null)).to.throw("You cannot have null as 'and' argument number 2.")
				expect(-> And(null, Number)).to.throw("You cannot have null as 'and' argument number 1.")

			it "And with literal value should throw an error.", ->
				expect(-> And(Number, 1))
				.to.throw("You cannot have literal Number 1 as 'and' argument number 2.")
				expect(-> And("foo", Number))
				.to.throw("You cannot have literal String \"foo\" as 'and' argument number 1.")

			it "And with literal values should throw an error.", ->
				expect(-> And(undefined, null, 1, "foo", true, NaN))
				.to.throw("You cannot have undefined as 'and' argument number 1.")

			it "isValid with and() should return true only if value in intersection of array types", ->
				t = And(Array(Number), Array(2))
				expect(isValid([1, 2], t)).to.be.true
				expect(isValid([1], t)).to.be.false
				expect(isValid([1, "two"], t)).to.be.false

			it "isValid with and() should return true only if value in intersection of unions of literal types", ->
				t = And(["foo", "bar"], ["bar", "baz"])
				expect(isValid("bar", t)).to.be.true
				expect(isValid("foo", t)).to.be.false
				expect(isValid("baz", t)).to.be.false

		context "Or", ->

			it "Or with a single value should throw an error", ->
				expect(-> Or(1)).to.throw("'or' must have at least 2 arguments.")

			it "Or with Any values should return an array and log a warning.", ->
				warnSpy.resetHistory()
				t = Or(Number, Any)
				expect(t).to.eql([Number, Any])
				expect(warnSpy.calledOnceWithExactly(
					"Any is inadequate as 'or' argument number 2."
				)).to.be.true

		context "Not", ->

			it "Not with more than a single value should throw an error", ->
				expect(-> Not(1, 2)).to.throw("'not' must have exactly 1 argument.")

			it "Not with Any value should return a Not instance and log a warning.", ->
				warnSpy.resetHistory()
				t = Not(Any)
				expect(t.constructor.name).to.equal("Not")
				expect(t.type).to.eql(Any)
				expect(warnSpy.calledOnceWithExactly(
					"Any is inadequate as 'not' argument."
				)).to.be.true

			it "isValid with not() should return true only if value is not of the given type", ->
				t = Not([String, Number])
				expect(isValid("foo", t)).to.be.false
				expect(isValid(1, t)).to.be.false
				expect(isValid(true, t)).to.be.true
				expect(isValid(false, t)).to.be.true
				expect(isValid(NaN, t)).to.be.true

	context "Regular expressions", ->

		it "should return true only for a regular expression value when type is RegExp", ->
			expect(isValid(/foo/, RegExp)).to.be.true
			expect(isValid("foo", RegExp)).to.be.false

		it "should test the value when type is a regular expression instance", ->
			expect(isValid("foo", /foo/)).to.be.true
			expect(isValid("bar", /foo/)).to.be.false
			expect(isValid("", /foo/)).to.be.false
			expect(isValid(/foo/, /foo/)).to.be.false
			expect(isValid(1, /foo/)).to.be.false

	context "Constraint", ->

		it "should return true when validator function is truthy for the value", ->
			Int = constraint((val) -> Number.isInteger(val))
			expect(isValid(100, Int)).to.be.true
			expect(isValid(-10, Int)).to.be.true
			expect(isValid(0, Int)).to.be.true
			expect(isValid(val, Int)).to.be.false for val in VALUES when not Number.isInteger(val)


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

		it "should not throw an error if no arguments types", ->
			f = fn Number, -> 1
			expect(f()).to.equal(1)

		it "should throw an error if signature result type is missing", ->
			expect(-> (fn -> 1))
			.to.throw("Result type is missing.")

		it "should throw an error if signature function to wrap is missing", ->
			expect(-> (fn Number, Number))
			.to.throw("Function to wrap is missing.")

		it "should throw an error if signature function to wrap is not an anonymous function", ->
			expect(-> (fn Number, Number, Number)).to.throw("Function to wrap is missing.")
			expect(-> (fn Number, Number, undefined)).to.throw("Function to wrap is missing.")
			expect(-> (fn Number, Number, null)).to.throw("Function to wrap is missing.")
			expect(-> (fn Number, Number, "foo")).to.throw("Function to wrap is missing.")
			expect(-> (fn Number, Number, Function)).to.throw("Function to wrap is missing.")
			expect(-> (fn Number, Number, foo = -> 1)).to.throw("Function to wrap is missing.")
			class Foo
			expect(-> (fn Number, Number, Foo)).to.throw("Function to wrap is missing.")

	context "Synchronous functions", ->

		it "should do nothing if function returns a string", ->
			f = fn undefined, String,
				-> "foo"
			expect(f()).to.equal("foo")

		it "should throw an error if function returns a number", ->
			f = fn undefined, String,
				-> 1
			expect(-> f()).to.throw("Result should be of type 'String' instead of Number 1.")

		it "should throw an error if function returns undefined", ->
			f = fn undefined, [String, Number],
				->
			expect(-> f()).to.throw("Result should be of type 'String or Number' instead of undefined.")

		it "should do nothing if function returns undefined", ->
			f = fn undefined, undefined,
				->
			expect(f()).to.equal(undefined)

	context "Asynchronous functions", ->

		it "should return a promise if function returns promise", ->
			f = fn undefined, promised(Number),
				-> Promise.resolve(1)
			expect(f()?.constructor).to.equal(Promise)

		it "should do nothing if function returns a string promise", ->
			f = fn undefined, promised(String),
				-> Promise.resolve("foo")
			expect(f()).to.eventually.equal("foo")

		it "should throw an error if function returns a number promise", ->
			f = fn undefined, promised(String),
				-> Promise.resolve(1)
			expect(f()).to.be.rejectedWith("Promise result should be of type 'String' instead of Number 1.")

		it "should throw an error if function does not return a promise", ->
			f = fn undefined, promised(String),
				-> '1'
			expect(f()).to.be.rejectedWith("Result should be a promise of type 'String' instead of String \"1\".")

		it "should throw an error if promised used without type", ->
			expect(-> fn undefined, promised(),
				-> Promise.resolve(1)
			).to.throw("'promised' must have exactly 1 argument.")

		it "should throw an error if promised used as a function", ->
			f = fn undefined, promised,
				-> Promise.resolve(1)
			expect(-> f()).to.throw("'promised' must have exactly 1 argument.")

	context "Arguments number", ->

		it "should do nothing if function has the right number of arguments", ->
			f = fn Number, [Number, String], Any,
				(n1, n2=0) -> n1 + n2
			expect(f(1, 2)).to.equal(3)

		it "should raise an error if function that takes no argument has an argument", ->
			f = fn Any,
				-> 1
			expect(-> f(1)).to.throw("Too many arguments provided.")

		it "should raise an error if function has too many arguments", ->
			f = fn Number, [Number, String], Any,
				(n1, n2=0) -> n1 + n2
			expect(-> f(1, 2, 3)).to.throw("Too many arguments provided.")

		it "should raise an error if function has too few arguments", ->
			f = fn Number, [Number, String], Any,
				(n1, n2=0) -> n1 + n2
			expect(-> f(1)).to.throw("Missing required argument number 2.")

		it "should do nothing if all unfilled arguments are optional", ->
			f = fn Number, [Number, String, undefined], Any,
				(n1, n2=0) -> n1 + n2
			expect(f(1)).to.equal(1)
			expect(f(1, undefined)).to.equal(1)
			f = fn Number, [Number, String, undefined], Number, Any,
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(f(1, undefined, 3)).to.equal(4)

		it "should do nothing if all unfilled arguments type is any type", ->
			f = fn Number, Any, Any,
				(n1, n2=0) -> n1 + n2
			expect(f(1)).to.equal(1)
			expect(f(1, undefined)).to.equal(1)
			f = fn Number, Any, Number, Any,
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(f(1, undefined, 3)).to.equal(4)

		it "should raise an error if some unfilled arguments are not optional", ->
			f = fn Number, [Number, String, undefined], Number, Any,
				(n1, n2=0, n3) -> n1 + n2 + n3
			expect(-> f(1)).to.throw("Missing required argument number 3.")
			expect(-> f(1, 2)).to.throw("Missing required argument number 3.")

		it "should raise an error when an optional argument is filled with null", ->
			f = fn Number, [Number, undefined], Any,
				(n1, n2=0) -> n1 + n2
			expect(-> f(1, null))
			.to.throw("Argument #2 should be of type 'Number or undefined' instead of null.")

		it "should raise an error when only an optional argument and value is null", ->
			f = fn undefined, Any,
				(n1=0) -> n1
			expect(-> f(null)).to.throw("Argument #1 should be of type 'undefined' instead of null.")

		it "should raise an error when only an optional argument and value isnt undefined", ->
			f = fn undefined, Any,
				(n1=0) -> n1
			expect(-> f(1)).to.throw("Argument #1 should be of type 'undefined' instead of Number 1.")

		it "should do nothing if only an optional argument and value is undefined", ->
			f = fn undefined, Any,
				(n1=0) -> n1
			expect(f(undefined)).to.equal(0)

		it "should do nothing if only an optional argument and value is not filled", ->
			f = fn undefined, Any,
				(n1=0) -> n1
			expect(f()).to.equal(0)

	context "Rest type", ->

		it "should return the concatenation of zero argument of String type", ->
			f = fn etc(String), String,
				(str...) -> str.join('')
			expect(f()).to.equal('')
			f = fn Number, etc(String), String,
				(n, str...) -> n + str.join('')
			expect(f(1)).to.equal('1')

		it "should return the concatenation of one argument of String type", ->
			f = fn etc(String), String,
				(str...) -> str.join('')
			expect(f('abc')).to.equal('abc')
			f = fn Number, etc(String), String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'abc')).to.equal('1abc')

		it "should return the concatenation of all the arguments of String type", ->
			f = fn etc(String), String,
				(str...) -> str.join('')
			expect(f('a', 'bc', 'def')).to.equal('abcdef')
			f = fn Number, etc(String), String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 'bc', 'def')).to.equal('1abcdef')

		it "should throw an error if an argument is not a string", ->
			f = fn etc(String), String,
				(str...) -> str.join('')
			expect(-> f('a', 5, 'def'))
			.to.throw("Argument #2 should be of type 'String' instead of Number 5.")
			f = fn Number, etc(String), String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 5, 'def'))
			.to.throw("Argument #3 should be of type 'String' instead of Number 5.")

		it "should throw an error if an argument is not a number", ->
			f = fn etc(Number), String,
				(str...) -> str.join('')
			expect(-> f('a', 5, 'def'))
			.to.throw("Argument #1 should be of type 'Number' instead of String \"a\".")
			f = fn Number, etc(Number), String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 5, 'def'))
			.to.throw("Argument #2 should be of type 'Number' instead of String \"a\".")

		it "should return the concatenation of all the arguments of String or Number type", ->
			f = fn etc([String, Number]), String,
				(str...) -> str.join('')
			expect(f('a', 1, 'def')).to.equal('a1def')
			f = fn Number, etc([String, Number]), String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 2, 'def')).to.equal('1a2def')

		it "should throw an error if an argument is not a string or a Number type", ->
			f = fn etc([String, Number]), String,
				(str...) -> str.join('')
			expect(-> f('a', true, 'def'))
			.to.throw("Argument #2 should be of type 'String or Number' instead of Boolean true.")
			f = fn Number, etc([String, Number]), String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', true, 'def'))
			.to.throw("Argument #3 should be of type 'String or Number' instead of Boolean true.")

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
			f = fn etc(String), String, String,
				(str...) -> str.join('')
			expect(-> f('a', 'bc', 'def'))
			.to.throw("Rest type must be the last of the arguments types.")
			f = fn Number, etc(String), String, String,
				(n, str...) -> n + str.join('')
			expect(-> f(1, 'a', 'bc', 'def'))
			.to.throw("Rest type must be the last of the arguments types.")

		it "should return the concatenation of all the arguments of any type", ->
			f = fn etc(Any), String,
				(str...) -> str.join('')
			expect(f('a', 5, 'def')).to.equal('a5def')
			f = fn Number, etc(Any), String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 5, 'def')).to.equal('1a5def')

		it "should behave like etc(Any) when type is ommited", ->
			f = fn etc(), String,
				(str...) -> str.join('')
			expect(f('a', 5, 'def')).to.equal('a5def')
			f = fn Number, etc(), String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 5, 'def')).to.equal('1a5def')

		it "should behave like etc(Any) when used as a function", ->
			f = fn etc, String,
				(str...) -> str.join('')
			expect(f('a', 5, 'def')).to.equal('a5def')
			f = fn Number, etc, String,
				(n, str...) -> n + str.join('')
			expect(f(1, 'a', 5, 'def')).to.equal('1a5def')

	context "Error messages", ->

		context "Uncomposed type argument", ->

			it "should return an error with 'undefined'", ->
				f = fn undefined, Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'undefined' instead of Number 1.")

			it "should return an error with 'null'", ->
				f = fn null, Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'null' instead of Number 1.")

			it "should return an error with 'String'", ->
				f = fn String, Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'String' instead of Number 1.")

			it "should return an error with
				'Argument number 1 should be of type 'Number' instead of Array.'", ->
				f = fn Number, Any, ->
				expect(-> f([1, 2]))
				.to.throw("Argument #1 should be of type 'Number' instead of Array.")

			it "should return an error with 'Array'", ->
				f = fn Array, Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'Array' instead of Number 1.")

			it "should return an error with 'literal String 'foo'", ->
				f = fn 'foo', Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'literal String \"foo\"' instead of Number 1.")

			it "should return an error with 'literal Number 1'", ->
				f = fn 1, Any, ->
				expect(-> f('1'))
				.to.throw("Argument #1 should be of type 'literal Number 1' instead of String \"1\".")

			it "should return an error with 'literal Boolean 'true'", ->
				f = fn true, Any, ->
				expect(-> f(false))
				.to.throw("Argument #1 should be of type 'literal Boolean true' instead of Boolean false.")

			it "should return an error with
				'Argument number 1 should be of type 'Number' instead of Object.'", ->
				f = fn Number, Any, ->
				expect(-> f(a: {b: 1, c: 2}, d: 3))
				.to.throw("Argument #1 should be of type 'Number' instead of Object.")

			it "should return an error with
				'Argument number 1 should be an object with key 'a.c' of type 'String' instead of Number 2.'", ->
				f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
				expect(-> f(a: {b: 1, c: 2}, d: 3))
				.to.throw("Argument #1 should be an object with key 'a.c' of type 'String' instead of Number 2.")

			it "should return an error with
				'Argument number 1 should be an object with key 'a.c' of type 'String' instead of missing key 'c'.'", ->
				f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
				expect(-> f(a: {b: 1, x: 4}, d: 3))
				.to.throw("Argument #1 should be an object with key 'a.c' of type 'String' instead of missing key 'c'.")

			it "should return an error with
				'Argument number 1 should be an object with key 'a.c' of type 'String' instead of undefined.'", ->
				f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
				expect(-> f(a: {b: 1, c: undefined, x: 4}, d: 3))
				.to.throw("Argument #1 should be an object with key 'a.c' of type 'String' instead of undefined.")

			it "should return an error with
				'Argument number 1 should be an object with key 'a.c' of type 'String' instead of Number 5.'", ->
				f = fn {a: {b: Number, c: String}, d: Number}, Any, ->
				expect(-> f(a: {b: 1, c: 5, x: 4}, d: 3))
				.to.throw("Argument #1 should be an object with key 'a.c' of type 'String' instead of Number 5.")

			it "should return an error with 'MyClass", ->
				class MyClass
				f = fn MyClass, Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'MyClass' instead of Number 1.")

			it "should return an error with 'array of'", ->
				f = fn Array(Number), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'array of 'Number'' instead of Number 1.")

			it "should return an error with 'array with element 1 of type 'Number' instead of String \"2\"'", ->
				f = fn Array(Number), Any, ->
				expect(-> f([1, '2', 3]))
				.to.throw("Argument #1 should be an array with element 1 of type 'Number' instead of String \"2\".")

			it "should return an error with 'array with a length of 4 instead of 3", ->
				f = fn Array(4), Any, ->
				expect(-> f([1, '2', 3]))
				.to.throw("Argument #1 should be an array with a length of 4 instead of 3.")

			it "should return an error with 'an array with a length of 2 instead of 3.", ->
				f = fn Array(2), Any, ->
				expect(-> f([1, '2', 3]))
				.to.throw("Argument #1 should be an array with a length of 2 instead of 3.")

			it "should return an error with 'of type 'Number or String' instead of Array", ->
				f = fn [Number, String], Any, ->
				expect(-> f([1]))
				.to.throw("Argument #1 should be of type 'Number or String' instead of Array.")

			it "should return an error with ''empty array' instead of Number 1.'", ->
				f = fn [], Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'empty array' instead of Number 1.")

			it "should return an error with 'empty array instead of a non-empty array'", ->
				f = fn [], Any, ->
				expect(-> f([1]))
				.to.throw("Argument #1 should be an empty array instead of a non-empty array.")

			it "should return an error with ''empty object' instead of Number 1.'", ->
				f = fn {}, Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'empty object' instead of Number 1.")

			it "should return an error with 'empty object instead of a non-empty object.'", ->
				f = fn {}, Any, ->
				expect(-> f({foo: "bar"}))
				.to.throw("Argument #1 should be an empty object instead of a non-empty object.")

			it "should return an error with 'NaN'", ->
				f = fn Number, Any, ->
				expect(-> f("a" * 2))
				.to.throw("Argument #1 should be of type 'Number' instead of NaN.")

			it "should return an error with 'RegExp'", ->
				f = fn /foo/, Any, ->
				expect(-> f("bar"))
				.to.throw("Argument #1 should be of type
							'string matching regular expression /foo/' instead of String \"bar\".")

		context "Union type argument", ->

			it "should return an error with 'undefined or null'", ->
				f = fn [undefined, null], Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'undefined or null' instead of Boolean true.")

			it "should return an error with 'String or Number'", ->
				f = fn [String, Number], Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'String or Number' instead of Boolean true.")

			it "should return an error with 'literal 'foo' or literal 'bar''", ->
				f = fn ['foo', 'bar'], Any, ->
				expect(-> f('a'))
				.to.throw("Argument #1 should be of type
							'literal String \"foo\" or literal String \"bar\"' instead of String \"a\".")

			it "should return an error with 'literal Number 1 or literal Number 2'", ->
				f = fn [1, 2], Any, ->
				expect(-> f(3))
				.to.throw("Argument #1 should be of type
							'literal Number 1 or literal Number 2' instead of Number 3.")

			it "should return an error with 'literal String \"1\" or literal Number '1'", ->
				f = fn ['1', 1], Any, ->
				expect(-> f(3))
				.to.throw("Argument #1 should be of type
							'literal String \"1\" or literal Number 1' instead of Number 3.")

			it "should return an error with 'literal Boolean true or literal Boolean false", ->
				f = fn [true, false], Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type
							'literal Boolean true or literal Boolean false' instead of Number 1.")

		context "Typed Array type argument", ->

			it "should return an error with 'array of 'Number''", ->
				f = fn Array(Number), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'array of 'Number'' instead of Number 1.")

			it "should return an error with 'array of 'Promise''", ->
				f = fn Array(Promise), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'array of 'Promise'' instead of Number 1.")

			it "should return an error with 'array of 'String or Number''", ->
				f = fn Array([String, Number]), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'array of 'String or Number'' instead of Number 1.")

			it "should return an error with 'array of 'object type object''", ->
				f = fn Array({a: String, b: Number}), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'array of 'object type'' instead of Number 1.")

			it "Array(Any) should return an error with 'array of 'any type''", ->
				f = fn Array(Any), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'array of 'any type'' instead of Number 1.")

			it "Array(Any)] should return an error with 'array of 'any type''", ->
				f = fn Array(Any), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'array of 'any type'' instead of Number 1.")

			it "Array(Any()) should return an error with 'array of 'any type''", ->
				f = fn Array(Any()), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'array of 'any type'' instead of Number 1.")

			it "Array(Number) should return an error with 'array with element 2 of type 'Number' instead of String.'", ->
				f = fn Array(Number), Any, ->
				expect(-> f([1, 2, "three", 4]))
				.to.throw("Argument #1 should be an array with element 2 of type 'Number' instead of String \"three\".")

			it "Array(Number) should return an error with
				'array with element 0 of type 'Number or String' instead of Boolean.'", ->
				f = fn Array([Number, String]), Any, ->
				expect(-> f([true]))
				.to.throw("Argument #1 should be an array with element 0 of type
							'Number or String' instead of Boolean true.")

		context "Tuple type argument", ->

			it "should return an error with 'tuple of 3 elements 'Number, Boolean, String''", ->
				f = fn Tuple(Number, Boolean, String), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'tuple of
							3 elements 'Number, Boolean, String'' instead of Number 1.")

			it "should return an error with 'tuple of 3 elements 'Number, Object or null, String''", ->
				f = fn Tuple(Number, [Object, null], String), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'tuple of
							3 elements 'Number, Object or null, String'' instead of Number 1.")

		context "Typed set type argument", ->

			it "should return an error with 'set of 'Number''", ->
				f = fn TypedSet(Number), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'set of 'Number'' instead of Number 1.")

			it "should return an error with 'set of 'String''", ->
				f = fn TypedSet(String), Any, ->
				expect(-> f(new Set(['a', 1])))
				.to.throw("Argument #1 should be of type 'set of 'String'' instead of Set.")

		context "Typed object type argument", ->

			it "should return an error with 'object with values of type 'Number''", ->
				f = fn TypedObject(Number), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'object with values of type 'Number'' instead of Number 1.")

			it "should return an error with 'set of 'String''", ->
				f = fn TypedObject(String), Any, ->
				expect(-> f({a: 'foo', b: 1}))
				.to.throw("Argument #1 should be of type 'object with values of type 'String'' instead of Object.")

		context "Typed map type argument", ->

			it "should return an error with 'map with values of type 'Number''", ->
				f = fn TypedMap(Number), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type 'map with values of type 'Number'' instead of Number 1.")

			it "should return an error with 'map with values of type 'String''", ->
				f = fn TypedMap(String), Any, ->
				expect(-> f(new Map([[1, 'foo'], [2, 2]])))
				.to.throw("Argument #1 should be of type 'map with values of type 'String'' instead of Map.")

			it "should return an error with 'map with keys of type 'Number' and values of type 'String''", ->
				f = fn TypedMap(Number, String), Any, ->
				expect(-> f(1))
				.to.throw("Argument #1 should be of type
							'map with keys of type 'Number' and values of type 'String'' instead of Number 1.")

			it "should return an error with
						''map with keys of type 'Number' and values of type 'String'' instead of Map.'", ->
				f = fn TypedMap(Number, String), Any, ->
				expect(-> f(new Map([[1, 'foo'], ['two', 'bar']])))
				.to.throw("Argument #1 should be of type
							'map with keys of type 'Number' and values of type 'String'' instead of Map.")

		context "Logical operators", ->

			# NB: Or() returns an array, not an Or instance, see array tests

			context "And", ->

				it "should return an error with ''array of 'Number'' and 'array of 3 elements''", ->
					f = fn And(Array(Number), Array(3)), Any, ->
					expect(-> f(1))
					.to.throw("Argument #1 should be of type
								''array of 'Number'' and 'array of 3 elements'' instead of Number 1.")

			context "Not", ->

				it "should return an error with 'not 'Number''", ->
					f = fn Not(Number), Any, ->
					expect(-> f(1))
					.to.throw("Argument #1 should be of type 'not 'Number'' instead of Number 1.")

				it "should return an error with 'not 'Number or array of 'Number'''", ->
					f = fn Not([Number, Array(Number)]), Any, ->
					expect(-> f(1))
					.to.throw("Argument #1 should be of type
								'not 'Number or array of 'Number''' instead of Number 1.")

		context "Integer", ->

			it "should return an error with 'Integer'", ->
				f = fn Integer, Any, ->
				expect(-> f(true)).to.throw("Argument #1 should be of type 'Integer' instead of Boolean true.")

			it "should return an error with 'Integer smaller than 100'", ->
				f = fn Integer(100), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'Integer smaller than 100' instead of Boolean true.")

			it "should return an error with 'Integer bigger than 100'", ->
				f = fn Integer(100, undefined), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'Integer bigger than 100' instead of Boolean true.")

			it "should return an error with 'Integer bigger than 10 and smaller than 100'", ->
				f = fn Integer(10, 100), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'Integer bigger than 10
							and smaller than 100' instead of Boolean true.")

			it "should return an error with 'Integer bigger than -100 and smaller than -10'", ->
				f = fn Integer(-100, -10), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'Integer bigger than -100
							and smaller than -10' instead of Boolean true.")

			it "should return an error with 'Integer bigger than -100 and smaller than 10'", ->
				f = fn Integer(-100, 10), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'Integer bigger than -100
							and smaller than 10' instead of Boolean true.")

			it "should return an error with ''Integer' max value cannot be less than min value", ->
				expect(-> Integer(100, -100))
				.to.throw("'Integer' max value cannot be less than min value.")


		context "Natural", ->

			it "should return an error with 'Natural'", ->
				f = fn Natural, Any, ->
				expect(-> f(true)).to.throw("Argument #1 should be of type 'Natural' instead of Boolean true.")

			it "should return an error with 'Natural smaller than 100'", ->
				f = fn Natural(100), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'Natural smaller than 100' instead of Boolean true.")

			it "should return an error with 'Natural bigger than 100'", ->
				f = fn Natural(100, undefined), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'Natural bigger than 100' instead of Boolean true.")

			it "should return an error with 'Natural bigger than 10 and smaller than 100'", ->
				f = fn Natural(10, 100), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'Natural bigger than 10
							and smaller than 100' instead of Boolean true.")

			it "should return an error with ''Natural' arguments must be positive numbers.'", ->
				expect(-> Natural(-100, -10)).to.throw("'Natural' arguments must be positive numbers.")
				expect(-> Natural(-100, 10)).to.throw("'Natural' arguments must be positive numbers.")

			it "should return an error with ''Natural' max value cannot be less than min value", ->
				expect(-> Natural(100, -100))
				.to.throw("'Natural' max value cannot be less than min value.")

		context "Sized string", ->

			it "should return an error with 'SizedString of at most 4 characters'", ->
				f = fn SizedString(100), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type
							'SizedString of at most 100 characters' instead of Boolean true.")

			it "should return an error with 'SizedString of at least 100 characters'", ->
				f = fn SizedString(10, undefined), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type
							'SizedString of at least 10 characters' instead of Boolean true.")

			it "should return an error with 'SizedString of at least 10 characters
						and of at most 100 characters'", ->
				f = fn SizedString(10, 100), Any, ->
				expect(-> f(true))
				.to.throw("Argument #1 should be of type 'SizedString of at least 10 characters
							and of at most 100 characters' instead of Boolean true.")

			it "should return an error with ''SizedString' arguments must be positive integers.'", ->
				expect(-> SizedString(-100, -10)).to.throw("'SizedString' arguments must be positive integers.")
				expect(-> SizedString(-100, 10)).to.throw("'SizedString' arguments must be positive integers.")
				expect(-> SizedString(undefined, -10)).to.throw("'SizedString' arguments must be positive integers.")
				expect(-> SizedString(-10, undefined)).to.throw("'SizedString' arguments must be positive integers.")

			it "should return an error with ''SizedString' max value cannot be less than min value", ->
				expect(-> SizedString(100, 10))
				.to.throw("'SizedString' max value cannot be less than min value.")

		context "Constraint", ->

			it "should return an error with ''constraint' argument must be a function.'", ->
				expect(-> constraint(1)).to.throw("'constraint' argument must be a function.")

			it "should return an error with 'constraint 'val => Number.isInteger(val)''", ->
				Int = constraint((val) -> Number.isInteger(val))
				f = fn Int, Number,
					(n) -> 1
				expect(-> f(2.5))
				.to.throw("Argument #1 should be of type
							'constrained by 'function (val) {\n          return Number.isInteger(val);\n        }''
							instead of Number 2.5.")

		context "Foreign", ->

			it "should return an error with 'foreign type'", ->
				f = fn foreign('Foo'), Any, ->
				expect(-> f(true)).to.throw("Argument #1 should be of type 'foreign type Foo' instead of Boolean true.")

			it "should return an error with 'foreign type with typed properties'", ->
				f = fn foreign({a: Number}), Any, ->
				expect(-> f(true)).to.throw("Argument #1 should be of type 'foreign type with typed properties' instead of Boolean true.")

		context "Result", ->

			it "should return a result error with ''Number' instead of NaN'", ->
				f = fn Number, [undefined, Number], Number,
					(a, b) -> a + b # missing default b value
				expect(-> f(1))
				.to.throw("Result should be of type 'Number' instead of NaN.")

describe "object", ->

	it "should init", ->
		o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
		expect(o).to.deep.equal({a: 1, b: {c: 2}})

	it "should shallow set", ->
		o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
		o.a = 3
		expect(o).to.deep.equal({a: 3, b: {c: 2}})

	it "should deep set", ->
		o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
		o.b.c = 3
		expect(o).to.deep.equal({a: 1, b: {c: 3}})

	it "should trow an error with a non-object type", ->
		expect(-> o = object Number, {a: 1, b: {c: 2}})
		.to.throw("'object' argument #1 must be an Object type.")

	it "should trow an error with a non-object object", ->
		expect(-> o = object {a: Number, b: {c: Number}}, "foo")
		.to.throw("'object' argument #2 should be of type 'object type' instead of String \"foo\"")

	it "should trow an error for a shallow type mismatch and leave object unmodified", ->
		o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
		expect(-> o.a = true)
		.to.throw("Object instance should be an object with key 'a' of type 'Number' instead of Boolean true.")
		expect(o).to.deep.equal({a: 1, b: {c: 2}})

	it "should trow an error for a deep type mismatch and leave object unmodified", ->
		o = object {a: Number, b: {c: Number}}, {a: 1, b: {c: 2}}
		expect(-> o.b.c = true)
		.to.throw("Object instance should be an object with key 'b.c' of type 'Number' instead of Boolean true.")
		expect(o).to.deep.equal({a: 1, b: {c: 2}})

	it "should trow an error for a deep-deep type mismatch and leave object unmodified", ->
		o = object {a: Number, b: {c: {d: Number}, e: Number}}, {a: 1, b: {c: {d: 2}, e: 3}}
		expect(-> o.b.c.d = true)
		.to.throw("Object instance should be an object with key 'b.c.d' of type 'Number' instead of Boolean true.")
		expect(o).to.deep.equal({a: 1, b: {c: {d: 2}, e: 3}})

	it "should trow an error when deleting key and leave object unmodified", ->
		o = object {a: Number, b: {c: {d: Number}, e: Number}}, {a: 1, b: {c: {d: 2}, e: 3}}
		expect(-> delete o.b.c)
		.to.throw("Object instance should be an object with key 'b.c' of type 'object type' instead of missing key 'c'.")
		expect(o).to.deep.equal({a: 1, b: {c: {d: 2}, e: 3}})

	it.skip "should trow an error when deleting undefined key and leave object unmodified", ->
		o = object {a: Number, b: {c: undefined}}, {a: 1, b: {c: undefined}}
		expect(-> delete o.b.c)
		.to.throw("Object instance should be an object with key 'b.c' of type undefined instead of missing key 'c'.")

describe "array", ->

	it "should init", ->
		a = array Number, [1, 2, 3]
		expect(a).to.eql([1, 2, 3])

	it "should set", ->
		a = array Number, [1, 2, 3]
		a.push(4)
		expect(a).to.eql([1, 2, 3, 4])

	it "should trow an error with a non-array type", ->
		expect(-> a = array Number, 1)
		.to.throw("'array' argument #2 should be of type 'array of 'Number'' instead of Number 1.")

	it "should trow an error for a push type mismatch", ->
		a = array Number, [1, 2, 3]
		expect(-> a.push(true))
		.to.throw("Array instance element 3 should be of type 'Number' instead of Boolean true.")

	it "should trow an error for a set type mismatch", ->
		a = array Number, [1, 2, 3]
		expect(-> a[1] = true)
		.to.throw("Array instance element 1 should be of type 'Number' instead of Boolean true.")

describe "tuple", ->

	it.skip "TODO!!!", ->
