import Type from './Type'
import Any from './Any'

class Etc extends Type
	# up to 1 argument
	argsMin: 0
	argsMax: 1
	constructor: (@type=Any) ->
		super(arguments...)
	validate: -> @error "'#{@helperName}' cannot be used in types."
	helperName: "etc"

export default Type.createHelper(Etc)
