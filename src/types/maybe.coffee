import Type from './Type'
import {isAny} from '../tools'

class Maybe extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		@warn "Any is not needed as '#{@helperName}' argument." if isAny(@type)
		# return needed to always return an array instead of a new Maybe instance
		return [undefined, null, @type]
	helperName: "maybe"

export default Type.createHelper(Maybe)
