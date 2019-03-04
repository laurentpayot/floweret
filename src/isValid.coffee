import {InvalidType} from './errors'
import {isAny, isEmptyObject} from './tools'
import typeOf from './typeOf'
import Type from './types/Type'

# check that a value is of a given type or of any (undefined) type, e.g.: isValid("foo", String)
isValid = (val, type) -> if Array.isArray(type) # NB: special Array case http://web.mit.edu/jwalden/www/isArray.html
	switch type.length
		when 0 then Array.isArray(val) and not val.length # empty array: `[]`
		when 1 then switch
			when not Array.isArray(val) then false
			when isAny(type[0]) then true
			when not Object.values(type).length then val.length is 1 # array of one empty value: sized array `Array(1)`
			else # typed array type, e.g.: `Array(String)`
				# optimizing for native types
				switch t = type[0] # not `f = switch…` to optimize CoffeeScript code generation
					when Number then f = Number.isFinite # Number.isFinite(NaN) is falsy
					when String, Boolean, Object then f = (e) -> try e.constructor is t
					when Array then f = Array.isArray
					else f = (e) -> isValid(e, t) # unoptimized
				val.every(f)
		else
			# NB: checking two first values instead of `Object.values(type).length` for performance reasons
			if type[0] is undefined and type[1] is undefined # array of empty values: sized array, e.g.: `Array(1000)`)
				Array.isArray(val) and val.length is type.length
			else # union of types, e.g.: `[Object, null]`
				type.some((t) -> isValid(val, t))
else switch type?.constructor
	when undefined, String, Number, Boolean # literal type (including ±Infinity and NaN) or undefined or null
		if Number.isNaN(type) then Number.isNaN(val) else val is type
	# custom type helpers, constructors of native types (String, Number (excluding ±Infinity), Object…), custom classes
	when Function then switch
		when type.rootClass is Type then type().validate(val) # type is a helper, using its default arguments
		when type is Array then Array.isArray(val)
		when type is Number then Number.isFinite(val)
		else val?.constructor is type
	when Object # Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		return false unless val?.constructor is Object
		if not isEmptyObject(type)
			for k, v of type
				return false unless isValid(val[k], v)
			true
		else isEmptyObject(val)
	when RegExp then val?.constructor is String and type.test(val)
	else
		if type instanceof Type
			type.validate(val)
		else
			prefix = if type.constructor in [Set, Map] then 'the provided Typed' else ''
			throw new InvalidType "Type can not be an instance of #{typeOf(type)}.
									Use #{prefix}#{typeOf(type)} as type instead."

export default isValid
