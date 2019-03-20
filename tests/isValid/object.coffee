import {VALUES} from '../fixtures'
import {isValid} from '../../dist'

test "return true if both value and type are empty object.", ->
	expect(isValid({}, {})).toBe(true)

test "return false if type is empty object but value unempty object.", ->
	expect(isValid({a: 1}, {})).toBe(false)

test "return false if value is empty object but type unempty object.", ->
	expect(isValid({}, {a: Number})).toBe(false)

test "return true if same object type but one more key.", ->
	expect(isValid({a: 1, b: 2, c: 'foo'}, {a: Number, b: Number})).toBe(true)

test "return false if same object type but one key less.", ->
	expect(isValid({a: 1}, {a: Number, b: Number})).toBe(false)

test "return false for an object type and non object values", ->
	UserType =
		id: Number
		name: String
	expect(isValid(undefined, UserType)).toBe(false)
	expect(isValid(null, UserType)).toBe(false)
	expect(isValid(val, UserType)).toBe(false) \
		for val in VALUES when val isnt undefined and val isnt null and val.constructor isnt Object

test "return true for a shallow object type, false otherwise", ->
	UserType =
		id: Number
		name: String
	expect(isValid({id: 1234, name: "Smith"}, UserType)).toBe(true)
	expect(isValid({id: 1234, name: "Smith", foo: "bar"}, UserType)).toBe(true)
	expect(isValid({foo: 1234, name: "Smith"}, UserType)).toBe(false)
	expect(isValid({id: '1234', name: "Smith"}, UserType)).toBe(false)
	expect(isValid({id: 1234, name: ["Smith"]}, UserType)).toBe(false)
	expect(isValid({name: "Smith"}, UserType)).toBe(false)
	expect(isValid({id: 1234}, UserType)).toBe(false)
	expect(isValid({}, UserType)).toBe(false)

test "return true for a deep object type, false otherwise", ->
	UserType =
		id: Number
		name:
			firstName: String
			lastName: String
			middleName: [String, undefined]
	expect(isValid({id: 1234, name: {firstName: "John", lastName: "Smith", middleName: "Jack"}}, UserType))
	.toBe(true)
	expect(isValid({id: 1234, name: {firstName: "John", lastName: "Smith", middleName: 1}}, UserType))
	.toBe(false)
	expect(isValid({id: 1234, name: {firstName: "John", lastName: "Smith"}}, UserType)).toBe(true)
	expect(isValid({id: 1234}, UserType)).toBe(false)
	expect(isValid({name: {firstName: "John", lastName: "Smith"}}, UserType)).toBe(false)
	expect(isValid({id: 1234, name: {firstName: "John"}}, UserType)).toBe(false)
	expect(isValid({id: 1234, name: {firstName: "John", lostName: "Smith"}}, UserType)).toBe(false)
	expect(isValid({id: 1234, name: {firstName: "John", lastName: [1]}}, UserType)).toBe(false)
	expect(isValid({id: '1234', name: "Smith"}, UserType)).toBe(false)
	expect(isValid({id: 1234, name: ["Smith"]}, UserType)).toBe(false)

test "return false for object type {name: 'Number'} and a number value", ->
	expect(isValid(1, {name: 'Number'})).toBe(false)
