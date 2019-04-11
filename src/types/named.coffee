import Type from './Type'

class NamedType extends Type
	# exacly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@name) ->
		super(arguments...)
		Type.invalid "'#{@helperName}' argument must be a non-empty string." unless typeof @name is 'string' and @name
	validate: (val) -> val?.constructor?.name is @name
	getTypeName: -> "a direct instance of #{@name}"
	helperName: "named"

export default Type.createHelper(NamedType)

