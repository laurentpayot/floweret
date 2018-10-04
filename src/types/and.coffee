import CustomType from './CustomType'
import isType from '../isType'
import {isAnyType, isLiteral, getTypeName} from '../tools'

class And extends CustomType
	# 2 or more arguments
	argsMin: 2
	constructor: (@types...) ->
		super(arguments...)
		for t, i in @types
			@error "You cannot have #{getTypeName(t)} as '#{@helperName}' argument number #{i+1}." if isLiteral(t)
			@warn "AnyType is not needed as '#{@helperName}' argument number #{i+1}." if isAnyType(t)
	validate: (val) -> @types.every((t) -> isType(val, t))
	getTypeName: -> ("'#{getTypeName(t)}'" for t in @types).join(" and ")
	helperName: "and"

export default CustomType.createHelper(And)
