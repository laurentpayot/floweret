import CustomType from './CustomType'
import {isAnyType} from '..'

class Maybe extends CustomType
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@warn "AnyType is not needed as '#{@helperName}' argument." if isAnyType(@type)
		# return needed to always return an array instead of a new Maybe instance
		return [undefined, null, @type]
	helperName: "maybe"

export default CustomType.createHelper(Maybe)
