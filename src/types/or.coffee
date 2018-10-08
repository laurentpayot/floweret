import Type from './Type'
import {isAny} from '../tools'

class Or extends Type
	# 2 or more arguments
	argsMin: 2
	constructor: (@types...) ->
		super(arguments...)
		@warn "Any is inadequate as '#{@helperName}' argument number #{i+1}." for t, i in @types when isAny(t)
		# return needed to always return an array instead of a new Or instance
		return @types
	helperName: "or"

export default Type.createHelper(Or)
