import {isValid} from '../../src'
import foreign from '../../src/types/foreign'

test "return true when value is an instance of the foreign constructor", ->
	class Foo extends String
	foo = new Foo('foo')
	expect(isValid(foo, foreign('Foo'))).toBe(true)

test "return false when value is not an instance of the foreign constructor", ->
	class Foo extends String
	foo = new Foo('foo')
	expect(isValid(foo, foreign('Bar'))).toBe(false)
	expect(isValid('baz', foreign('Foo'))).toBe(false)

test "return true when value has the same property types", ->
	class Foo extends String
		bar: true
		baz: 0
	foo = new Foo('foo')
	expect(isValid(foo, foreign({bar: Boolean}))).toBe(true)
	expect(isValid(foo, foreign({bar: Boolean, baz: Number}))).toBe(true)
	expect(isValid(foo, foreign({bar: Boolean, baz: Number, boo: undefined}))).toBe(true)

test "return false when value has not the same property types", ->
	class Foo extends String
		bar: true
		baz: 0
	foo = new Foo('foo')
	expect(isValid(foo, foreign({bar: Boolean, baz: String}))).toBe(false)
	expect(isValid(foo, foreign({bar: Boolean, baz: Number, boo: String}))).toBe(false)
	expect(isValid(foo, foreign({bar: Boolean, baz: Number, boo: String}))).toBe(false)
