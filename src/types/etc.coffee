{Type} = require '.'

class Etc extends Type
	constructor: (@type=[]) ->
		super(arguments, 0, 1) # up to 1 argument
	validate: -> Type.error "'#{@helperName}' cannot be used in types."
	helperName: "etc"

module.exports = Type.createHelper(Etc)
