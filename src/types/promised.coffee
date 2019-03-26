import Type from './Type'
import {isAny} from '../tools'

class Promised extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		Type.warn "Use 'Promise' type instead of '#{@helperName}(Any)'." if isAny(@type)
		# return needed to always return a promise instead of a new Promised instance
		return Promise.resolve(@type)
	helperName: "promised"

export default Type.createHelper(Promised)
