import {isValid} from '../../src'
import TypedObject from '../../src/types/TypedObject'

test "throw an error when TypedObject is used as a function", ->
	expect(-> isValid(1, TypedObject)).toThrow("'TypedObject' must have exactly 1 argument.")

test "throw an error when TypedObject is used without arguments", ->
	expect(-> isValid(1, TypedObject())).toThrow("'TypedObject' must have exactly 1 argument.")

# TODO: more tests!!!!!!!!!!!!!!!!!!!!!!
