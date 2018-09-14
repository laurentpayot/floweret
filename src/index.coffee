###* @license MIT (c) 2018 Laurent Payot  ###

{Type, InvalidTypeError} = require './types'
AnyType = require './types/AnyType'

class InvalidSignatureError extends Error
	constructor: (msg) -> super("Invalid signature: " + msg)

class TypeError extends Error
	constructor: (msg) -> super("Type not matching: " + msg)

# trows customized error
error = (msg) -> switch msg[0]
	when '!' then throw new InvalidTypeError msg[1..]
	when '@' then throw new InvalidSignatureError msg[1..]
	else throw new TypeError msg

AnyTypeClass = AnyType().constructor
isAnyType = (o) -> Array.isArray(o) and o.length is 0 or o is AnyType or o instanceof AnyTypeClass

### type helpers ###

promised = (type) ->
	error "!'promised' must have exactly 1 argument." unless arguments.length is 1
	if isAnyType(type) then Promise else Promise.resolve(type)

class Etc # typed rest arguments list
	constructor: (@type=[]) -> error "!'etc' must have at most 1 argument." if arguments.length > 1
etc = -> new Etc(arguments...)

# typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for null, Promise etc.
typeOf = (val) -> if val is undefined or val is null then '' + val else val.constructor.name

# check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
isType = (val, type) -> if Array.isArray(type) # NB: special Array case http://web.mit.edu/jwalden/www/isArray.html
	switch type.length
		when 0 then true # any type: `[]`
		when 1
			return false unless Array.isArray(val)
			return true if isAnyType(type[0])
			unless Object.values(type).length # array of one empty value: sized array `Array(1)`
				val.length is 1
			else # typed array type, e.g.: `Array(String)`
				val.every((e) -> isType(e, type[0]))
		else
			# NB: checking two first values instead of `Object.values(type).length` for performance reasons
			if type[0] is undefined and type[1] is undefined # array of empty values: sized array, e.g.: `Array(1000)`)
				return false unless Array.isArray(val)
				val.length is type.length
			else
				type.some((t) -> isType(val, t)) # union of types, e.g.: `[Object, null]`
else switch type?.constructor
	when undefined, String, Number, Boolean then val is type # literal type or undefined or null
	when Function then switch type
		# type helpers used directly as functions
		when AnyType then true
		when promised then error "!'#{type.name}' can not be used directly as a function."
		when etc then error "!'etc' can not be used in types."
		else
			if type.rootClass is Type # type is a helper
				type().validate(val) # using default helper arguments
			else # constructors of native types (Number, String, Object, Array, Promise, Set, Map…) and custom classes
				val?.constructor is type
	when Object # Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		return false unless val?.constructor is Object
		for k, v of type
			return false unless isType(val[k], v)
		true
	when Etc then error "!'etc' can not be used in types."
	else
		if type instanceof Type
			type.validate(val)
		else
			prefix = if type.constructor in [Set, Map] then 'the provided Typed' else ''
			error "!Type can not be an instance of #{typeOf(type)}. Use #{prefix}#{typeOf(type)} as type instead."

# returns a list of keys path to where the type do not match + value not maching + type not matching
badPath = (obj, typeObj) ->
	for k, t of typeObj
		if not isType(obj[k], t)
			return [k].concat(if obj[k]?.constructor is Object then badPath(obj[k], typeObj[k]) \
								else [obj[k], typeObj[k]])

# returns the type name for signature error messages (supposing type is always correct)
typeName = (type) -> switch type?.constructor
	when undefined then typeOf(type)
	when Array then switch type.length
		when 0 then "any type"
		when 1 then "array of '#{typeName(type[0])}'"
		else (typeName(t) for t in type).join(" or ")
	when Function
		if type.rootClass is Type then type().typeName() else type.name
	when Object then "custom type object"
	else
		if type instanceof Type then type.typeName() else "literal #{typeOf(type)} '#{type}'"

# type error message comparison part helper
shouldBe = (val, type) ->
	if val?.constructor is Object
		[bp..., bv, bt] = badPath(val, type)
		"should be an object with key '#{bp.join('.')}' of type #{typeName(bt)} instead of #{typeOf(bv)}"
	else
		"(#{val}) should be of type #{typeName(type)} instead of #{typeOf(val)}"

# wraps a function to check its arguments types and result type
fn = (argTypes, resType, f) ->
	error "@Array of arguments types is missing." unless Array.isArray(argTypes)
	error "@Result type is missing." if resType?.constructor is Function and not resType.name
	error "@Function to wrap is missing." unless f?.constructor is Function
	(args...) -> # returns an unfortunately anonymous function
		rest = false
		for type, i in argTypes
			if type is etc or type?.constructor is Etc # rest type
				error "@Rest type must be the last of the arguments types." if i + 1 < argTypes.length
				rest = true
				t = if type is etc then [] else type.type
				unless isAnyType(t)
					for arg, j in args[i..]
						error "Argument number #{i+j+1} #{shouldBe(arg, t)}." unless isType(arg, t)
			else
				unless isAnyType(type)
					if args[i] is undefined
						error "Missing required argument number #{i+1}." unless isType(undefined, type)
					else
						error "Argument number #{i+1} #{shouldBe(args[i], type)}." unless isType(args[i], type)
		error "Too many arguments provided." if args.length > argTypes.length and not rest
		if resType?.constructor is Promise
			# NB: not using `await` because CS would transpile the returned function as an async one
			resType.then((promiseType) ->
				promise = f(args...)
				error "Function should return a promise." unless promise?.constructor is Promise
				promise.then((result) ->
					error "Promise result #{shouldBe(result, promiseType)}." unless isType(result, promiseType)
					result
				)
			)
		else
			result = f(args...)
			error "Result #{shouldBe(result, resType)}." unless isType(result, resType)
			result


module.exports = {fn, promised, etc, typeOf, isType, isAnyType, typeName}
