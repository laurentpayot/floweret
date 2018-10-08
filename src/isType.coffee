import {InvalidType} from './errors'
import {isAnyType} from './tools'
import typeOf from './typeOf'
import Type from './types/Type'

# check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
isType = (val, type) -> if Array.isArray(type) # NB: special Array case http://web.mit.edu/jwalden/www/isArray.html
	switch type.length
		when 0 then true # any type: `[]`
		when 1 then switch
			when not Array.isArray(val) then false
			when isAnyType(type[0]) then true
			when not Object.values(type).length then val.length is 1 # array of one empty value: sized array `Array(1)`
			else val.every((e) -> isType(e, type[0])) # typed array type, e.g.: `Array(String)`
		else
			# NB: checking two first values instead of `Object.values(type).length` for performance reasons
			if type[0] is undefined and type[1] is undefined # array of empty values: sized array, e.g.: `Array(1000)`)
				Array.isArray(val) and val.length is type.length
			else
				type.some((t) -> isType(val, t)) # union of types, e.g.: `[Object, null]`
else switch type?.constructor
	when undefined, String, Number, Boolean # literal type (including ±Infinity and NaN) or undefined or null
		if Number.isNaN(type) then Number.isNaN(val) else val is type
	when Function
		if type.rootClass is Type # type is a helper
			type().validate(val) # using default helper arguments
		else # constructors of native types (String, Number (excluding ±Infinity), Object…) and custom classes
			if type is Number then Number.isFinite(val) else val?.constructor is type
	when Object # Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		return false unless val?.constructor is Object
		for k, v of type
			return false unless isType(val[k], v)
		true
	when RegExp then val?.constructor is String and type.test(val)
	else
		if type instanceof Type
			type.validate(val)
		else
			prefix = if type.constructor in [Set, Map] then 'the provided Typed' else ''
			throw new InvalidType "Type can not be an instance of #{typeOf(type)}.
									Use #{prefix}#{typeOf(type)} as type instead."

export default isType
