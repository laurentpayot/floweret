import Type from './Type'

class Foreign extends Type
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@foreignTypeName) ->
		super(arguments...)
		@error "'#{@helperName}' argument must be a string." unless typeof @foreignTypeName is 'string'
	validate: (val) -> val?.constructor?.name is @foreignTypeName
	getTypeName: -> "foreign type #{@foreignTypeName}"
	helperName: "foreign"

export default Type.createHelper(Foreign)

