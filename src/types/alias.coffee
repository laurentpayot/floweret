import Type from './Type'
import isValid from '../isValid'
import check from '../check'
import {getTypeName} from '../tools'

class Alias extends Type
	# exacly 2 arguments
	argsMin: 2
	argsMax: 2
	constructor: (name, @type) ->
		super(arguments...)
		# return needed to return an instance of @type
		return @type.alias(name) if @type instanceof Type or @type?.rootClass is Type
		@alias(name) # name validation by Type alias method
	validate: (val) -> isValid(val, @type)
	getTypeName: -> @aliasName
	helperName: "alias"
	# for object and array types
	checkWrap: (val, context) -> check(@type, val, context, @aliasName)

export default Type.createHelper(Alias)
