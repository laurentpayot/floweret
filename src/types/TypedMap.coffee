{Type, InvalidTypeError, createHelper} = require '.'
{isType, isAnyType} = require '..'

class TypedMap extends Type
	keysType: []
	valuesType: []
	constructor: (t1, t2) ->
		super()
		switch arguments.length
			when 0 then throw new InvalidTypeError "TypedMap must have at least one type argument."
			when 1
				if isAnyType(t1) then return Map else @valuesType = t1 # return needed
			when 2
				if isAnyType(t1) and isAnyType(t2) then return Map else [@keysType, @valuesType] = [t1, t2] # return needed
			else throw new InvalidTypeError "TypedMap can not have more than two type arguments."
	validate: (val) ->
		return false unless val?.constructor is Map
		switch
			when isAnyType(@keysType) and isAnyType(@valuesType) then true
			when isAnyType(@keysType) then Array.from(val.values()).every((e) => isType(e, @valuesType))
			when isAnyType(@valuesType) then Array.from(val.keys()).every((e) => isType(e, @keysType))
			else
				keys = Array.from(val.keys())
				values = Array.from(val.values())
				keys.every((e) => isType(e, @keysType)) and values.every((e) => isType(e, @valuesType))

module.exports = createHelper(TypedMap)
