import Type from './types/Type'
import AnyTypeHelper from './types/AnyType'
import typeOf from './typeOf'

AnyType = AnyTypeHelper().constructor
isAnyType = (o) -> Array.isArray(o) and o.length is 0 or o is AnyTypeHelper or o instanceof AnyType

# returns true if value is a literal
isLiteral = (val) -> val?.constructor in [undefined, String, Number, Boolean] # NaN and ±Infinity are numbers

# show the type of the value and eventually the value itself
typeValue = (val) ->
	t = typeOf(val)
	t + switch t
		when 'String' then ' "' + val + '"'
		when 'Number', 'Boolean', 'RegExp' then ' ' + val
		else ''

# returns the type name for signature error messages (supposing type is always correct)
getTypeName = (type) -> if Array.isArray(type) # NB: special Array case http://web.mit.edu/jwalden/www/isArray.html
	typedArray = not Object.values(type).length
	switch type.length
		when 0 then "any type"
		when 1
			if typedArray then "array of one element" else "array of '#{getTypeName(type[0])}'"
		else
			if typedArray then "array of #{type.length} elements" else (getTypeName(t) for t in type).join(" or ")
else switch type?.constructor
	when undefined then typeOf(type)
	when Function
		if type.rootClass is Type then type().getTypeName() else type.name
	when Object then "object type"
	when RegExp then "string matching regular expression " + type
	else
		if type instanceof Type
			type.getTypeName()
		else
			"literal #{typeValue(type)}"

export {isAnyType, isLiteral, typeValue, getTypeName}
