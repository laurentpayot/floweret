import {isValid} from '../../dist'
import named from '../../dist/types/named'
import type from '../../dist/types/type'

test "return true when value is an instance of the named constructor", ->
	class Foo extends String
	foo = new Foo('foo')
	expect(isValid(foo, named('Foo'))).toBe(true)

test "return false when value is not an instance of the named constructor", ->
	class Foo extends String
	foo = new Foo('foo')
	expect(isValid(foo, named('Bar'))).toBe(false)
	expect(isValid('foo', named('Foo'))).toBe(false)
	expect(isValid(type({a: Number}).as('Foo'), named('Foo'))).toBe(false)
