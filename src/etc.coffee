CustomType = require './CustomType'

class Etc extends CustomType
	constructor: (@type=[]) ->
		super(arguments, 0, 1) # up to 1 argument
	validate: -> CustomType.error "'#{@helperName}' cannot be used in types."
	helperName: "etc"

module.exports = CustomType.createHelper(Etc)
