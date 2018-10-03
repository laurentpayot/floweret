import CustomType from './CustomType'
import {isAnyType} from '.'

class Or extends CustomType
	# 2 or more arguments
	argsMin: 2
	constructor: (@types...) ->
		super(arguments...)
		@warn "AnyType is inadequate as '#{@helperName}' argument number #{i+1}." for t, i in @types when isAnyType(t)
		# return needed to always return an array instead of a new Or instance
		return @types
	helperName: "or"

export default CustomType.createHelper(Or)
