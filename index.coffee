CHECK_TYPES = process?.env.NODE_ENV is 'development' or !!process?.env.RUNTIME_SIGNATURE_CHECK_TYPES

# shortcut to Promise.resolve
promised = (t) -> Promise.resolve(t)

# typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for Promise etc.
typeOf = (val) -> Object.prototype.toString.call(val)[8...-1]

# check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
isType = (val, type) ->
	switch
		when type is undefined then val is undefined
		when type is null then val is null
		when Array.isArray(type)
			switch type.length
				when 0 then true # any type: `[]`
				when 1 # typed array type, e.g.: `Array(String)`
					unless Array.isArray(val) then false else val.every((v) -> isType(v, type[0]))
				else # array of possible types, e.g.: `[Object, null]`
					type.some((t) -> isType(val, t))
		# native type: Number, String, Object, Array (untyped), Promise etc…
		when typeof type is 'function' then typeOf(val) is type.name
		# custom type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
		when typeof type is 'object'
			throw new Error "Type can not be an empty object." unless Object.keys(type).length
			return false unless typeOf(val) is 'Object'
			for k, v of type
				return false unless isType(val[k], v)
			true
		else # type is not a class but an instance
			throw new Error "Type can not be '#{type}'. Use #{typeOf(type)} class instead."

# not exported: get type name for sig error messages (supposing type is always correct)
typeName = (type) ->
	switch
		when Array.isArray(type)
			if type.length is 1
				"array of #{typeName(type[0])}."
			else
				(typeName(t) for t in type).join(" or ")
		when typeof type is 'function' then type.name
		when isType(type, Object) then "custom type"
		else typeOf(type)

# check function in/out types, e.g.:
# f = sig [String, Number], String,
#     (str, num) -> str + num
sig = (argTypes, resType, f) ->
	return f unless CHECK_TYPES
	-> # using JS keyword `arguments` instead of (args...) -> …
		throw new Error "Too many arguments provided." unless arguments.length <= argTypes.length
		for type, i in argTypes
			unless Array.isArray(type) and not type.length # not checking type if any type
				if arguments[i] is undefined
					throw new Error "Missing required argument number #{i+1}." unless isType(undefined, type)
				else
					throw new Error "Argument number #{i+1} (#{arguments[i]}) should be of type #{typeName(type)}
									instead of #{typeOf(arguments[i])}." unless isType(arguments[i], type)
		# to specify type of a promise function, use Promise.resolve(<type>) as resType,
		if isType(resType, Promise)
			# NB: not using `await` because CS would transpile the returned function (of the factory) as an async one!!!
			resType.then((promiseType) ->
				promise = f(arguments...)
				throw new Error "Function should return a promise." unless isType(promise, Promise)
				promise.then((result) ->
					throw new Error "Promise result (#{result}) should be of type #{typeName(promiseType)}
									instead of #{typeOf(result)}." unless isType(result, promiseType)
					result
				)
			)
		else
			result = f(arguments...)
			throw new Error "Result (#{result}) should be of type #{typeName(resType)}
							instead of #{typeOf(result)}." unless isType(result, resType)
			result


module.exports = {typeOf, isType, sig, promised}