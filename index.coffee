###* @license MIT (c) 2018 Laurent Payot  ###

# trows customized error
error = (msg) -> throw new Error switch msg[0]
	when '!' then "Invalid type syntax: #{msg[1..]}"
	when '@' then "Invalid signature: #{msg[1..]}"
	else "Type error: #{msg}"

### typed classes ###

class _Tuple
	constructor: (@types...) ->
		error "!Tuple must have at least two type arguments." if arguments.length < 2
		return Array if @types.every((t) -> isAnyType(t)) # return needed

class _TypedObject
	constructor: (@type) ->
		error "!TypedObject must have exactly one type argument." unless arguments.length is 1
		return Object if isAnyType(@type) # return needed

class _TypedSet
	constructor: (@type) ->
		error "!TypedSet must have exactly one type argument." unless arguments.length is 1
		return Set if isAnyType(@type) # return needed

class _TypedMap
	keysType: []
	valuesType: []
	constructor: (t1, t2) -> switch arguments.length
		when 0 then error "!TypedMap must have at least one type argument."
		when 1
			if isAnyType(t1) then return Map else @valuesType = t1 # return needed
		when 2
			if isAnyType(t1) and isAnyType(t2) then return Map else [@keysType, @valuesType] = [t1, t2] # return needed
		else error "!TypedMap can not have more than two type arguments."

class _Etc # typed rest arguments list
	constructor: (@type=[]) -> error "!'etc' can not have more than one type argument." if arguments.length > 1

# not exported
isAnyType = (o) -> o is AnyType or Array.isArray(o) and o.length is 0

### type helpers ###

AnyType = -> if arguments.length then error "!'AnyType' can not have a type argument." else []
maybe = (types...) ->
	error "!'maybe' must have at least one type argument." unless arguments.length
	if types.some((t) -> isAnyType(t)) then [] else [undefined, null].concat(types)
promised = (type) ->
	error "!'promised' must have exactly one type argument." unless arguments.length is 1
	if isAnyType(type) then Promise else Promise.resolve(type)

Tuple = (args...) -> new _Tuple(args...)
TypedObject = (args...) -> new _TypedObject(args...)
TypedSet = (args...) -> new _TypedSet(args...)
TypedMap = (args...) -> new _TypedMap(args...)
etc = (args...) -> new _Etc(args...)

# typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for null, Promise etc.
typeOf = (val) -> if val is undefined or val is null then '' + val else val.constructor.name

# check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
isType = (val, type) -> if Array.isArray(type) # NB: special Array case http://web.mit.edu/jwalden/www/isArray.html
	switch type.length
		when 0 then true # any type: `[]`
		when 1 # typed array type, e.g.: `Array(String)`
			return false unless Array.isArray(val)
			return true if isAnyType(type[0])
			val.every((e) -> isType(e, type[0]))
		else type.some((t) -> isType(val, t)) # union of types, e.g.: `[Object, null]`
else switch type?.constructor
	when undefined, String, Number, Boolean then val is type # literal type or undefined or null
	when Function then switch type
		# type helpers used directly as functions
		when AnyType then true
		when promised, maybe, TypedObject, TypedSet, TypedMap
			error "!'#{type.name}' can not be used directly as a function."
		when etc then error "!'etc' can not be used in types."
		# constructors of native types (Number, String, Object, Array, Promise, Set, Map…) and custom classes
		else val?.constructor is type
	when Object # Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		return false unless val?.constructor is Object
		return true unless Object.keys(type).length
		for k, v of type
			return false unless isType(val[k], v)
		true
	when _Tuple
		types = type.types
		return false unless Array.isArray(val) and val.length is types.length
		val.every((e, i) -> isType(e, types[i]))
	when _TypedObject
		return false unless val?.constructor is Object
		t = type.type
		return true if isAnyType(t)
		Object.values(val).every((v) -> isType(v, t))
	when _TypedSet
		return false unless val?.constructor is Set
		t = type.type
		return true if isAnyType(t)
		error "!Typed Set type can not be a literal
				of type '#{t}'." if typeOf(t) in ['undefined', 'null', 'String', 'Number', 'Boolean']
		[val...].every((e) -> isType(e, t))
	when _TypedMap
		return false unless val?.constructor is Map
		{keysType, valuesType} = type
		switch
			when isAnyType(keysType) and isAnyType(valuesType) then true
			when isAnyType(keysType) then Array.from(val.values()).every((e) -> isType(e, valuesType))
			when isAnyType(valuesType) then Array.from(val.keys()).every((e) -> isType(e, keysType))
			else
				keys = Array.from(val.keys())
				values = Array.from(val.values())
				keys.every((e) -> isType(e, keysType)) and values.every((e) -> isType(e, valuesType))
	when _Etc then error "!'etc' can not be used in types."
	else
		prefix = if type.constructor in [Set, Map] then 'the provided Typed' else ''
		error "!Type can not be an instance of #{typeOf(type)}. Use #{prefix}#{typeOf(type)} as type instead."

# returns a list of keys path to where the type do not match + value not maching + type not matching
badPath = (obj, typeObj) ->
	for k, t of typeObj
		if not isType(obj[k], t)
			return [k].concat(if obj[k]?.constructor is Object then badPath(obj[k], typeObj[k]) else [obj[k], typeObj[k]])

# returns the type name for signature error messages (supposing type is always correct)
typeName = (type) -> if isAnyType(type) then "any type" else switch type?.constructor
	when undefined then typeOf(type)
	when Array
		if type.length is 1 then "array of '#{typeName(type[0])}'" else (typeName(t) for t in type).join(" or ")
	when Function then type.name
	when Object then "custom type object"
	when _Tuple then "tuple of #{type.types.length} elements '#{(typeName(t) for t in type.types).join(", ")}'"
	else "literal #{typeOf(type)} '#{type}'"

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
			if type is etc or type?.constructor is _Etc # rest type
				error "@Rest type must be the last of the arguments types." if i + 1 < argTypes.length
				rest = true
				t = if type is etc then [] else type.type
				unless isAnyType(t) # no checks if rest type is any type
					for arg, j in args[i..]
						error "Argument number #{i+j+1} #{shouldBe(arg, t)}." unless isType(arg, t)
			else
				unless isAnyType(type) # not checking type if type is any type
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


module.exports = {typeOf, isType, fn, maybe, AnyType, promised, etc, Tuple, TypedObject, TypedSet, TypedMap}
