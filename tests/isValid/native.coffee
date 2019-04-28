import {testTypes} from '../fixtures'
import {isValid} from '../../dist'


test "return true for an undefined type, false for other types", ->
	testTypes(undefined, undefined)

test "return true for a null type, false for other types", ->
	testTypes(null, null)

test "return true for NaN type, false for other types", ->
	expect(isValid(NaN, NaN)).toBe(true)
	expect(isValid(Number, NaN)).toBe(false)
	expect(isValid(NaN, 1)).toBe(false)
	testTypes(NaN, NaN)

test "return true for Infinity type, false for other types", ->
	expect(isValid(Infinity, Infinity)).toBe(true)
	expect(isValid(Number, Infinity)).toBe(false)
	expect(isValid(Infinity, 1)).toBe(false)
	testTypes(Infinity, Infinity)

test "return true for -Infinity type, false for other types", ->
	expect(isValid(-Infinity, -Infinity)).toBe(true)
	expect(isValid(Number, -Infinity)).toBe(false)
	expect(isValid(-Infinity, -1)).toBe(false)
	testTypes(-Infinity, -Infinity)

test "return true for a number type, false for other types", ->
	testTypes(1.1, Number)
	testTypes(0, Number)

test "return true for a boolean type, false for other types", ->
	testTypes(true, Boolean)
	testTypes(false, Boolean)

test "return true for a string type, false for other types", ->
	testTypes('', String)
	testTypes("Énorme !", String)

test "return true for an array type, false for other types", ->
	testTypes([1, 'a'], Array)

test "return true for a date type, false for other types", ->
	testTypes(new Date(), Date)

test "return true for an object type, false for other types", ->
	testTypes({}, Object)
	testTypes({foo: 'bar'}, Object)

test "return true for a set type, false for other types", ->
	testTypes(new Set([]), Set)
	testTypes(new Set([1, 2]), Set)

test "return true for a promise type, false for other types", ->
	testTypes(new Promise(->), Promise)
	testTypes(new Promise((resolve, reject) -> resolve()), Promise)

test "return true for a function type, false for other types", ->
	testTypes((->), Function)
	testTypes(((a)-> a + 1), Function)

test "return true for a factory function value and function type, false for other types", ->
	testTypes(((foo) -> ((bar)-> foo + bar)), Function)
	testTypes(((foo) -> ((bar)-> new Promise((resolve, reject) -> resolve(foo + bar)))), Function)
