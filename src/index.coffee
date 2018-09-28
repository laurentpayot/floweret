###* Floweret @license MIT (c) 2018 Laurent Payot ###

CustomType = require './CustomType'
AnyTypeHelper = require './AnyType'
EtcHelper = require './etc'

class InvalidSignature extends Error
class TypeMismatch extends Error
error = (msg) -> if msg[0] is '@' then throw new InvalidSignature msg[1..] else throw new TypeMismatch msg

Etc = EtcHelper().constructor
AnyType = AnyTypeHelper().constructor
isAnyType = (o) -> Array.isArray(o) and o.length is 0 or o is AnyTypeHelper or o instanceof AnyType

# typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for null, NaN, Promise etc.
typeOf = (val) -> if val in [undefined, null] or Number.isNaN(val) then '' + val else val.constructor.name

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
	when undefined, String, Number, Boolean # literal type or undefined or null or NaN (NaN.constuctor is Number!)
		if Number.isNaN(type) then Number.isNaN(val) else val is type
	when Function
		if type.rootClass is CustomType # type is a helper
			type().validate(val) # using default helper arguments
		else # constructors of native types (Number, String, Object, Array, Promise, Set, Map…) and custom classes
			not Number.isNaN(val) and val?.constructor is type # NB: NaN.constuctor is Number
	when Object # Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		return false unless val?.constructor is Object
		for k, v of type
			return false unless isType(val[k], v)
		true
	when RegExp then val?.constructor is String and type.test(val)
	else
		if type instanceof CustomType
			type.validate(val)
		else
			prefix = if type.constructor in [Set, Map] then 'the provided Typed' else ''
			CustomType.error "Type can not be an instance of #{typeOf(type)}.
								Use #{prefix}#{typeOf(type)} as type instead."

# returns a list of keys path to the mismatched type + value not maching + type not matching
badPath = (obj, typeObj) ->
	for k, t of typeObj
		if not isType(obj[k], t)
			return [k].concat(if obj[k]?.constructor is Object then badPath(obj[k], typeObj[k]) \
								else [obj[k], typeObj[k]])

# show the type of the value and eventually the value itself
typeValue = (val) -> (t = typeOf(val)) + switch t
	when 'String' then ' "' + val + '"'
	when 'Number', 'Boolean', 'RegExp' then ' ' + val
	else ''

# returns the type name for signature error messages (supposing type is always correct)
getTypeName = (type) -> switch type?.constructor
	when undefined then typeOf(type)
	when Array then switch type.length
		when 0 then "any type"
		when 1 then "array of '#{getTypeName(type[0])}'"
		else (getTypeName(t) for t in type).join(" or ")
	when Function
		if type.rootClass is CustomType then type().getTypeName() else type.name
	when Object then "object type"
	when RegExp then "string matching regular expression " + type
	else
		if type instanceof CustomType
			type.getTypeName()
		else
			"literal #{typeValue(type)}"

# type error message comparison part helper
shouldBe = (val, type, promised=false) ->
	apo = if promised then "a promise of " else ''
	"should be " + switch
		when Array.isArray(val) and Array.isArray(type)
			i = val.findIndex((e) -> not isType(e, type[0]))
			"#{apo}an array with element #{i} of type '#{getTypeName(type[0])}' instead of #{typeValue(val[i])}"
		when val?.constructor is Object and type?.constructor is Object
			[bp..., bv, bt] = badPath(val, type)
			"#{apo}an object with key '#{bp.join('.')}' of type '#{getTypeName(bt)}' instead of #{typeValue(bv)}"
		else
			"#{apo or 'of type '}'#{getTypeName(type)}' instead of #{typeValue(val)}"

# wraps a function to check its arguments types and result type
fn = (argTypes, resType, f) ->
	error "@Array of arguments types is missing." unless Array.isArray(argTypes)
	error "@Result type is missing." if resType instanceof Function and not resType.name
	error "@Function to wrap is missing." unless f instanceof Function and not f.name
	error "@Too many arguments." if arguments.length > 3
	(args...) -> # returns an unfortunately anonymous function
		rest = false
		for type, i in argTypes
			if type is EtcHelper or type instanceof Etc # rest type
				error "@Rest type must be the last of the arguments types." if i + 1 < argTypes.length
				rest = true
				t = (if type is EtcHelper then type() else type).type # using default helper parameters
				unless isAnyType(t)
					for arg, j in args[i..]
						error "Argument ##{i+j+1} #{shouldBe(arg, t)}." unless isType(arg, t)
			else
				unless isAnyType(type)
					if args[i] is undefined
						error "Missing required argument number #{i+1}." unless isType(undefined, type)
					else
						error "Argument ##{i+1} #{shouldBe(args[i], type)}." unless isType(args[i], type)
		error "Too many arguments provided." if args.length > argTypes.length and not rest
		if resType instanceof Promise
			# NB: not using `await` because CS would transpile the returned function as an async one
			resType.then((promiseType) ->
				promise = f(args...)
				error "Result #{shouldBe(promise, promiseType, true)}." unless promise instanceof Promise
				promise.then((result) ->
					error "Promise result #{shouldBe(result, promiseType)}." unless isType(result, promiseType)
					result
				)
			)
		else
			result = f(args...)
			error "Result #{shouldBe(result, resType)}." unless isType(result, resType)
			result

module.exports = {fn, typeOf, isType, isAnyType, getTypeName}
