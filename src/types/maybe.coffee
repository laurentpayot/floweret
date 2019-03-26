import Type from './Type'
import {isAny} from '../tools'

class Maybe extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		# throwing error to avoid returning [undefined, undefined], same as sized array Array(2)
		Type.invalid "'#{@helperName}' argument cannot be undefined." if @type is undefined
		Type.warn "Any is not needed as '#{@helperName}' argument." if isAny(@type)
		# return needed to always return an array instead of a new Maybe instance
		return [undefined, @type]
	helperName: "maybe"

export default Type.createHelper(Maybe)
