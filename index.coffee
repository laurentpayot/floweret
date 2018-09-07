# trows customized error
error = (msg) -> throw new Error switch msg[0]
	when '!' then "Invalid type syntax: #{msg[1..]}"
	when '@' then "Invalid signature: #{msg[1..]}"
	else "Type error: #{msg}"


### typed classes ###

class TypedObject
	constructor: (@type) ->
		error "!typedObject must have exactly one type argument." unless arguments.length is 1
		# NB: return needed to force constructor to return Object instead of new TypedObject instance
		return Object if isAnyType(@type)

class TypedSet
	constructor: (@type) ->
		error "!typedSet must have exactly one type argument." unless arguments.length is 1
		# NB: return needed to force constructor to return Set instead of new TypedSet instance
		return Set if isAnyType(@type)

class TypedMap
	keysType: []
	valuesType: []
	constructor: (type1, type2) -> switch arguments.length
		when 0 then error "!typedMap must have at least one type argument."
		# NB: returns needed to force constructor to return Map instead of new TypedMap instance
		when 1
			if isAnyType(type1) then return Map else @valuesType = type1
		when 2
			if isAnyType(type1) and isAnyType(type2) then return Map else [@keysType, @valuesType] = [type1, type2]
		else error "!typedMap can not have more than two type arguments."


# not exported
isAnyType = (o) -> o is anyType or Array.isArray(o) and o.length is 0

### type helpers ###

anyType = -> if arguments.length then error "!'anyType' can not have a type argument." else []
maybe = (types...) ->
	error "!'maybe' must have at least one type argument." unless arguments.length
	if types.some((t) -> isAnyType(t)) then [] else [undefined, null].concat(types)
promised = (type) ->
	error "!'promised' must have exactly one type argument." unless arguments.length is 1
	if isAnyType(type) then Promise else Promise.resolve(type)
etc = (type) -> switch arguments.length
	when 0 then etc
	when 1 then (_etc = -> type) # returns a function with name property '_etc'
	else error "!'etc' can not have more than one type argument."
typedObject = (args...) -> new TypedObject(args...)
typedSet = (args...) -> new TypedSet(args...)
typedMap = (args...) -> new TypedMap(args...)

# typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for null, Promise etc.
# NB: returning string instead of class because of special array case http://web.mit.edu/jwalden/www/isArray.html
typeOf = (val) -> if val is undefined or val is null then '' + val else val.constructor.name

# check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
isType = (val, type) -> switch typeOf(type)
	when 'undefined', 'null', 'String', 'Number', 'Boolean' then val is type # literal type or undefined or null
	when 'Function' then switch type
		# type helpers used directly as functions
		when anyType then true
		when promised, maybe, typedObject, typedSet, typedMap
			error "!'#{type.name}' can not be used directly as a function."
		when etc then error "!'etc' can not be used in types."
		# constructors of native types (Number, String, Object, Array, Promise, Set, Map…) and custom classes
		else val?.constructor is type
	when 'Array' then switch type.length
		when 0 then true # any type: `[]`
		when 1 # typed array type, e.g.: `Array(String)`
			return false unless Array.isArray(val)
			return true if isAnyType(type[0])
			val.every((e) -> isType(e, type[0]))
		else type.some((t) -> isType(val, t)) # union of types, e.g.: `[Object, null]`
	when 'Object' # Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		return false unless val?.constructor is Object
		return not Object.keys(val).length unless Object.keys(type).length
		for k, v of type
			return false unless isType(val[k], v)
		true
	when 'TypedObject'
		return false unless val?.constructor is Object
		t = type.type
		return true if isAnyType(t)
		Object.values(val).every((v) -> isType(v, t))
	when 'TypedSet'
		return false unless val?.constructor is Set
		t = type.type
		return true if isAnyType(t)
		error "!Typed Set type can not be a literal
				of type '#{t}'." if typeOf(t) in ['undefined', 'null', 'String', 'Number', 'Boolean']
		[val...].every((e) -> isType(e, t))
	when 'TypedMap'
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
	else
		prefix = if typeOf(type) in ['Set', 'Map', 'WeakSet', 'WeakMap'] then 'the provided Typed' else ''
		error "!Type can not be an instance of #{typeOf(type)}. Use #{prefix}#{typeOf(type)} as type instead."

# not exported: get type name for signature error messages (supposing type is always correct)
typeName = (type) -> switch typeOf(type)
	when 'Array'
		if type.length is 1
			"array of #{typeName(type[0])}"
		else
			(typeName(t) for t in type).join(" or ")
	when 'Function' then type.name
	when 'Object' then "custom type"
	else typeOf(type)

# wraps a function to check its arguments types and result type
sig = (argTypes, resType, f) ->
	error "@Array of arguments types is missing." unless Array.isArray(argTypes)
	error "@Result type is missing." if resType?.constructor is Function and not resType.name
	error "@Function to wrap is missing." unless f?.constructor is Function
	(args...) -> # returns an unfortunately anonymous function
		rest = false
		for type, i in argTypes
			if typeof type is 'function' and (type.name is '_etc' or type is etc) # rest type
				error "@Rest type must be the last of the arguments types." if i + 1 < argTypes.length
				rest = true
				t = type()
				unless type is etc or isAnyType(t) # no checks if rest type is any type
					for arg, j in args[i..]
						error "Argument number #{i+j+1} (#{arg}) should be of type #{typeName(type())}
								instead of #{typeOf(arg)}." unless isType(arg, t)
			else
				unless isAnyType(type) # not checking type if type is any type
					if args[i] is undefined
						error "Missing required argument number #{i+1}." unless isType(undefined, type)
					else
						error "Argument number #{i+1} (#{args[i]}) should be of type #{typeName(type)}
								instead of #{typeOf(args[i])}." unless isType(args[i], type)
		error "Too many arguments provided." if args.length > argTypes.length and not rest
		if isType(resType, Promise)
			# NB: not using `await` because CS would transpile the returned function as an async one
			resType.then((promiseType) ->
				promise = f(args...)
				error "Function should return a promise." unless isType(promise, Promise)
				promise.then((result) ->
					error "Promise result (#{result}) should be of type #{typeName(promiseType)}
							instead of #{typeOf(result)}." unless isType(result, promiseType)
					result
				)
			)
		else
			result = f(args...)
			error "Result (#{result}) should be of type #{typeName(resType)}
					instead of #{typeOf(result)}." unless isType(result, resType)
			result


module.exports = {typeOf, isType, sig, maybe, anyType, promised, etc, typedObject, typedSet, typedMap}
