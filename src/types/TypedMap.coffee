Type = require '.'
{isType, isAnyType} = require '..'

class TypedMap extends Type
	keysType: []
	valuesType: []
	constructor: (t1, t2) ->
		super(arguments, 1, 2) # 1 or 2 arguments
		if arguments.length is 1
			if isAnyType(t1) then return Map else @valuesType = t1 # return needed
		else
			if isAnyType(t1) and isAnyType(t2) then return Map else [@keysType, @valuesType] = [t1, t2] # return needed
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

module.exports = Type.createHelper(TypedMap)
