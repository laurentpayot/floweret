import {getTypeName, typeValue, isEmptyObject} from './tools'
import isValid from './isValid'
import Type from './types/Type'

# returns a list of keys path to the mismatched type + value not maching + type not matching
badPath = (obj, typeObj) ->
	for k, t of typeObj
		return [k, obj, typeObj[k]] if isEmptyObject(obj)
		# second or clause in case key not in obj and type is undefined
		if not isValid(obj[k], t) or isEmptyObject(obj[k]) and t?.constructor is Object
			return [k].concat(if obj[k]?.constructor is Object then badPath(obj[k], typeObj[k]) \
								else [obj[k], typeObj[k]])

# type error message comparison part helper
shouldBe = (val, type, promised=false) ->
	io = " instead of "
	"should be #{if promised then "a promise of " else ''}" + switch
		when Array.isArray(val) and Array.isArray(type) and (type.length is 1 or not Object.values(type).length)
			if type.length
				if not Object.values(type).length # sized array
					"an array with a length of #{type.length}#{io}#{val.length}"
				else
					i = val.findIndex((e) -> not isValid(e, type[0]))
					"an array with element #{i} of type '#{getTypeName(type[0])}'#{io}#{typeValue(val[i])}"
			else
				"an empty array#{io}a non-empty array"
		when val?.constructor is Object and type?.constructor is Object
			if not isEmptyObject(type)
				[bp..., bv, bt] = badPath(val, type)
				bk = bp[bp.length - 1]
				"an object with key '#{bp.join('.')}' of type '#{getTypeName(bt)}'#{io}#{\
					if bv is undefined and bk not in Object.keys(bp[...-1].reduce(((acc, curr) -> acc[curr]), val))\
						or bv?.constructor is Object and isEmptyObject(bv)\
					then "missing key '" + bk + "'" else typeValue(bv)}"
			else
				"an empty object#{io}a non-empty object"
		else
			"#{if promised then '' else "of "}type '#{getTypeName(type)}'#{io}#{typeValue(val)}"

typeError = (prefix='', val, type, promised) ->
	throw new TypeError prefix + if arguments.length > 1 then  ' ' + shouldBe(val, type, promised) + '.' else ''

# NB: to avoid circular dependencies, error static method is added to Type class here instead of `Type` file
Type.error = typeError

export default typeError
