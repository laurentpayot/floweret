# trows customized error
error = (msg) -> throw new Error switch msg[0]
	when '!' then "Invalid type syntax: #{msg[1..]}"
	when '@' then "Invalid signature: #{msg[1..]}"
	else "Type error: #{msg}"

# type helpers
anyType = -> if arguments.length then error "!You can not specify a type for 'anyType'." else []
isAnyType = (o) -> o is anyType or Array.isArray(o) and o.length is 0 # not exported
maybe = (t) ->
	error "!You must specify a type for 'maybe'." if not arguments.length
	if isAnyType(t) then [] else [undefined, null, t]
promised = (t) -> if not arguments.length then error "!You must specify a type for 'promised'." else Promise.resolve(t)
etc = (t=[]) -> (_etc = -> t) # returns a function with name property '_etc'
_Set = (t=[]) -> if isAnyType(t) then Set else new Set([t])
_Map = (t1=[], t2=[]) ->
	switch arguments.length
		when 0 then return Map
		when 1
			if isAnyType(t1) then return Map else [keysType, valuesType] = [[], t1]
		when 2
			if isAnyType(t1) and isAnyType(t2) then return Map else [keysType, valuesType] = [t1, t2]
		else error "!Typed map type '_Map' can not have more than two arguments."
	new Map([[keysType, valuesType]])

# typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for null, Promise etc.
# NB: returning string instead of class because of special array case http://web.mit.edu/jwalden/www/isArray.html
typeOf = (val) -> if val is undefined or val is null then '' + val else val.constructor.name

# not exported: get type name for error messages (supposing type is always correct)
typeName = (type) -> switch typeOf(type)
	when 'Array'
		if type.length is 1
			"array of #{typeName(type[0])}"
		else
			(typeName(t) for t in type).join(" or ")
	when 'Function' then type.name
	when 'Object' then "custom type"
	else typeOf(type)

# check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
isType = (val, type) -> switch typeOf(type)
	when 'undefined', 'null', 'String', 'Number', 'Boolean' then val is type # literal type or undefined or null
	when 'Function' then switch type
		# type helpers used directly as functions
		when anyType then true
		when _Set then val?.constructor is Set
		when _Map then val?.constructor is Map
		when promised, maybe then error "!You can not use '#{type.name}' directly as a function."
		# constructors of native types (Number, String, Object, Array, Promise, Set, Map…) and custom classes
		else val?.constructor is type
	when 'Array' then switch type.length
		when 0 then true # any type: `[]`
		when 1 # typed array type, e.g.: `Array(String)`
			unless Array.isArray(val) then false else val.every((e) -> isType(e, type[0]))
		else # union of types, e.g.: `[Object, null]`
			type.some((t) -> isType(val, t))
	when 'Set'
		error "!Typed set must have one and only one type." unless type.size is 1
		return false unless val?.constructor is Set
		t = [type...][0]
		error "!You can not have a typed Set
				of literal type '#{t}'." if typeOf(t) in ['undefined', 'null', 'String', 'Number', 'Boolean']
		[val...].every((e) -> isType(e, t))
	when 'Map'
		error "!Typed map must have one and only one pair of types." unless type.size is 1
		return false unless val?.constructor is Map
		[keysType, valuesType] = Array.from(type)[0]
		switch
			when isAnyType(keysType) and isAnyType(valuesType) then true
			when isAnyType(keysType) then Array.from(val.values()).every((e) -> isType(e, valuesType))
			when isAnyType(valuesType) then Array.from(val.keys()).every((e) -> isType(e, keysType))
			else
				keys = Array.from(val.keys())
				values = Array.from(val.values())
				keys.every((e) -> isType(e, keysType)) and values.every((e) -> isType(e, valuesType))
	when 'Object' # Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		return false unless val?.constructor is Object
		return not Object.keys(val).length unless Object.keys(type).length
		for k, v of type
			return false unless isType(val[k], v)
		true
	else # type is not a class but an instance
		error "!Type can not be an instance of #{typeName(type)}. Use the #{typeName(type)} class as type instead."

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


module.exports = {typeOf, isType, sig, maybe, anyType, promised, etc, _Set, _Map}
