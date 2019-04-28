import {isValid} from '../../dist'
import named from '../../dist/types/named'
import alias from '../../dist/types/alias'

test "return true when value is an instance of the named constructor", ->
	class Foo extends String
	foo = new Foo('foo')
	expect(isValid(named('Foo'), foo)).toBe(true)

test "return false when value is not an instance of the named constructor", ->
	class Foo extends String
	foo = new Foo('foo')
	expect(isValid(named('Bar'), foo)).toBe(false)
	expect(isValid(named('Foo'), 'foo')).toBe(false)
	expect(isValid(alias('Foo', {a: Number}), named('Foo'))).toBe(false)
