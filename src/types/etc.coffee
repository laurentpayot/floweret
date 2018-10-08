import Type from './Type'

class Etc extends Type
	# up to 1 argument
	argsMin: 0
	argsMax: 1
	constructor: (@type=[]) ->
		super(arguments...)
	validate: -> @error "'#{@helperName}' cannot be used in types."
	helperName: "etc"

export default Type.createHelper(Etc)
