CustomType = require './CustomType'
{isType, isAnyType, getTypeName} = require '.'

class TypedMap extends CustomType
	valuesType: []
	keysType: []
	isKeysType: false
	constructor: (t1, t2) ->
		super(arguments, 1, 2) # 1 or 2 arguments
		if arguments.length is 1
			CustomType.warn "Use 'Map' type instead of a #{@constructor.name}
							with values of any type." if isAnyType(t1)
			@valuesType = t1
		else
			@isKeysType = true
			CustomType.warn "Use 'Map' type instead of a #{@constructor.name}
							with keys and values of any type." if isAnyType(t1) and isAnyType(t2)
			[@keysType, @valuesType] = [t1, t2]
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
	getTypeName: ->
		kt = if @isKeysType then "keys of type '#{getTypeName(@keysType)}' and " else ''
		"map with #{kt}values of type '#{getTypeName(@valuesType)}'"

module.exports = CustomType.createHelper(TypedMap)
