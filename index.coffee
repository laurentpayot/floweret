# trows customized error
error = (msg) -> throw new Error switch msg[0]
	when '@' then "Signature: #{msg[1..]}"
	when '!' then "Invalid type syntax: #{msg[1..]}"
	else "Type error: #{msg}"

# shortcuts
maybe = (t) -> [undefined, null, t] # checking undefined and null types first
promised = (t) -> Promise.resolve(t)
_Set = (t) -> if t is undefined then Set else new Set([t])
# _Map = (t) -> new Map([t])

# rest type: returns a function whose name property is 'etc' that returns the type of the rest elements
etc = (t) -> (etc = -> t)

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
	when 'Function' then val?.constructor is type # native type: Number, String, Object, Array (untyped), Promise…
	when 'Array'
		switch type.length
			when 0 then true # any type: `[]`
			when 1 # typed array type, e.g.: `Array(String)`
				unless Array.isArray(val) then false else val.every((e) -> isType(e, type[0]))
			else # union of types, e.g.: `[Object, null]`
				type.some((t) -> isType(val, t))
	when 'Set'
		error "!Typed set must have one and only one type." unless type.size is 1
		unless val?.constructor is Set then false else
			t = [type...][0]
			[val...].every((e) -> isType(e, t))
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
		for type, i in argTypes
			if typeof type is 'function' and type.name is 'etc' # rest type
				error "@Rest type must be the last of the arguments types." if i+1 < argTypes.length
				for arg, j in args[i..]
					error "Argument number #{i+j+1} (#{arg}) should be of type #{typeName(type())}
							instead of #{typeOf(arg)}." unless isType(arg, type())
			else
				unless Array.isArray(type) and not type.length # not checking type if type is any type (`[]`)
					if args[i] is undefined
						error "Missing required argument number #{i+1}." unless isType(undefined, type)
					else
						error "Argument number #{i+1} (#{args[i]}) should be of type #{typeName(type)}
								instead of #{typeOf(args[i])}." unless isType(args[i], type)
		error "Too many arguments provided." if args.length > argTypes.length and typeof j is 'undefined'
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


module.exports = {typeOf, isType, sig, maybe, promised, etc, _Set}
