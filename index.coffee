# trows customized error
error = (msg) -> throw new Error "Type error: #{msg}"

# shortcuts
maybe = (t) -> [undefined, null, t] # checking undefined and null types first
promised = (t) -> Promise.resolve(t)
_Set = (t) -> if t is undefined then Set else new Set([t])
# _Map = (t) -> new Map([t])

# typeOf([]) is Array, whereas typeof [] is 'object'. Same for null, Promise etc.
typeOf = (val) -> if val is undefined or val is null then val else val.constructor

# not exported: get type name for error messages (supposing type is always correct)
typeName = (type) -> switch typeOf(type)
	when Array
		if type.length is 1
			"array of #{typeName(type[0])}."
		else
			(typeName(t) for t in type).join(" or ")
	when Function then type.name
	when Object then "custom type"
	else typeOf(type)?.name or ''+type

# check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
isType = (val, type) -> switch typeOf(type)
	when undefined, null, String, Number, Boolean then val is type # literal type or undefined or null
	when Function then typeOf(val) is type # native type: Number, String, Object, Array (untyped), Promise…
	when Array
		switch type.length
			when 0 then true # any type: `[]`
			when 1 # typed array type, e.g.: `Array(String)`
				unless Array.isArray(val) then false else val.every((v) -> isType(v, type[0]))
			else # union of types, e.g.: `[Object, null]`
				type.some((t) -> isType(val, t))
	when Object # Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		return false unless typeOf(val) is Object
		return not Object.keys(val).length unless Object.keys(type).length
		for k, v of type
			return false unless isType(val[k], v)
		true
	else # type is not a class but an instance
		error "Type can not be an instance of #{typeName(type)}. Use the #{typeName(type)} class as type instead."

# wraps a function to check its arguments types and result type
sig = (argTypes, resType, f) ->
	error "Signature: Array of arguments types is missing." unless Array.isArray(argTypes)
	error "Signature: Result type is missing." if resType?.constructor is Function and not resType.name
	error "Signature: Function to wrap is missing." unless resType?.constructor is Function
	-> # returns an unfortunately anonymous function
		error "Too many arguments provided." unless arguments.length <= argTypes.length
		for type, i in argTypes
			unless Array.isArray(type) and not type.length # not checking type if type is any type (`[]`)
				if arguments[i] is undefined
					error "Missing required argument number #{i+1}." unless isType(undefined, type)
				else
					error "Argument number #{i+1} (#{arguments[i]}) should be of type #{typeName(type)}
							instead of #{typeName(arguments[i])}." unless isType(arguments[i], type)
		if isType(resType, Promise)
			# NB: not using `await` because CS would transpile the returned function as an async one
			resType.then((promiseType) ->
				promise = f(arguments...)
				error "Function should return a promise." unless isType(promise, Promise)
				promise.then((result) ->
					error "Promise result (#{result}) should be of type #{typeName(promiseType)}
							instead of #{typeName(result)}." unless isType(result, promiseType)
					result
				)
			)
		else
			result = f(arguments...)
			error "Result (#{result}) should be of type #{typeName(resType)}
					instead of #{typeName(result)}." unless isType(result, resType)
			result


module.exports = {typeOf, isType, sig, maybe, promised}
