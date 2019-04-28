import {isValid} from '../../dist'
import TypedObject from '../../dist/types/TypedObject'

test "throw an error when TypedObject is used as a function", ->
	expect(-> isValid(TypedObject, 1)).toThrow("'TypedObject' must have exactly 1 argument.")

test "throw an error when TypedObject is used without arguments", ->
	expect(-> isValid(TypedObject(), 1)).toThrow("'TypedObject' must have exactly 1 argument.")

# TODO: more tests!!!!!!!!!!!!!!!!!!!!!!
