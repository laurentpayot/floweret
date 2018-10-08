import Type from './Type'
import isType from '../isType'
import {isAnyType, isLiteral, getTypeName} from '../tools'

notDefined = (t) -> t is undefined or isAnyType(t)

class TypedMap extends Type
	valuesType: undefined
	keysType: undefined
	# 1 or 2 arguments
	argsMin: 1
	argsMax: 2
	constructor: (t1, t2) ->
		super(arguments...)
		if arguments.length is 1
			@warn "Use 'Map' type instead of a #{@constructor.name} with values of any type." if isAnyType(t1)
			@valuesType = t1
		else
			@error "You cannot have both #{getTypeName(t1)} as keys type and #{getTypeName(t2)} as values type
					in a #{@constructor.name}." if isLiteral(t1) and isLiteral(t2)
			@warn "Use 'Map' type instead of a #{@constructor.name}
					with keys and values of any type." if isAnyType(t1) and isAnyType(t2)
			# [@keysType, @valuesType] = [t1, t2] # problem with Rollup commonjs plugin
			@keysType = t1
			@valuesType = t2
	validate: (val) ->
		return false unless val?.constructor is Map
		switch
			when notDefined(@keysType) and notDefined(@valuesType) then true
			when notDefined(@keysType) then Array.from(val.values()).every((e) => isType(e, @valuesType))
			when notDefined(@valuesType) then Array.from(val.keys()).every((e) => isType(e, @keysType))
			else
				keys = Array.from(val.keys())
				values = Array.from(val.values())
				keys.every((e) => isType(e, @keysType)) and values.every((e) => isType(e, @valuesType))
	getTypeName: ->
		kt = if @keysType isnt undefined then "keys of type '#{getTypeName(@keysType)}' and " else ''
		"map with #{kt}values of type '#{getTypeName(@valuesType)}'"

export default Type.createHelper(TypedMap)
