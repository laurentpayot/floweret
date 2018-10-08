import Type from './Type'
import {isAnyType} from '../tools'

class Maybe extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@warn "AnyType is not needed as '#{@helperName}' argument." if isAnyType(@type)
		# return needed to always return an array instead of a new Maybe instance
		return [undefined, null, @type]
	helperName: "maybe"

export default Type.createHelper(Maybe)
