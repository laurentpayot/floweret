import {VALUES} from '../fixtures'
import {isValid} from '../../dist'

test "return true if both value and type are empty object.", ->
	expect(isValid({}, {})).toBe(true)

test "return false if type is empty object but value unempty object.", ->
	expect(isValid({}, {a: 1})).toBe(false)

test "return false if value is empty object but type unempty object.", ->
	expect(isValid({a: Number}, {})).toBe(false)

test "return true if same object type but one more key.", ->
	expect(isValid({a: Number, b: Number}, {a: 1, b: 2, c: 'foo'})).toBe(true)

test "return false if same object type but one key less.", ->
	expect(isValid({a: Number, b: Number}, {a: 1})).toBe(false)

test "return false for an object type and non object values", ->
	UserType =
		id: Number
		name: String
	expect(isValid(UserType, undefined)).toBe(false)
	expect(isValid(UserType, null)).toBe(false)
	expect(isValid(UserType, val)).toBe(false) \
		for val in VALUES when val isnt undefined and val isnt null and val.constructor isnt Object

test "return true for a shallow object type, false otherwise", ->
	UserType =
		id: Number
		name: String
	expect(isValid(UserType, {id: 1234, name: "Smith"})).toBe(true)
	expect(isValid(UserType, {id: 1234, name: "Smith", foo: "bar"})).toBe(true)
	expect(isValid(UserType, {foo: 1234, name: "Smith"})).toBe(false)
	expect(isValid(UserType, {id: '1234', name: "Smith"})).toBe(false)
	expect(isValid(UserType, {id: 1234, name: ["Smith"]})).toBe(false)
	expect(isValid(UserType, {name: "Smith"})).toBe(false)
	expect(isValid(UserType, {id: 1234})).toBe(false)
	expect(isValid(UserType, {})).toBe(false)

test "return true for a deep object type, false otherwise", ->
	UserType =
		id: Number
		name:
			firstName: String
			lastName: String
			middleName: [String, undefined]
	expect(isValid(UserType, {id: 1234, name: {firstName: "John", lastName: "Smith", middleName: "Jack"}}))
	.toBe(true)
	expect(isValid(UserType, {id: 1234, name: {firstName: "John", lastName: "Smith", middleName: 1}}))
	.toBe(false)
	expect(isValid(UserType, {id: 1234, name: {firstName: "John", lastName: "Smith"}})).toBe(true)
	expect(isValid(UserType, {id: 1234})).toBe(false)
	expect(isValid(UserType, {name: {firstName: "John", lastName: "Smith"}})).toBe(false)
	expect(isValid(UserType, {id: 1234, name: {firstName: "John"}})).toBe(false)
	expect(isValid(UserType, {id: 1234, name: {firstName: "John", lostName: "Smith"}})).toBe(false)
	expect(isValid(UserType, {id: 1234, name: {firstName: "John", lastName: [1]}})).toBe(false)
	expect(isValid(UserType, {id: '1234', name: "Smith"})).toBe(false)
	expect(isValid(UserType, {id: 1234, name: ["Smith"]})).toBe(false)

test "return false for object type {name: 'Number'} and a number value", ->
	expect(isValid({name: 'Number'}, 1)).toBe(false)
