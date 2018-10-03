import {CustomType} from './CustomType'

class Etc extends CustomType
	# up to 1 argument
	argsMin: 0
	argsMax: 1
	constructor: (@type=[]) ->
		super(arguments...)
	validate: -> @error "'#{@helperName}' cannot be used in types."
	helperName: "etc"

h = CustomType.createHelper(Etc)
export {h as etc}
