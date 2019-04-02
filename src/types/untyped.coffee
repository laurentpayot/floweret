import Type from './Type'
import isValid from '../isValid'
import {getTypeName} from '../tools'

class Untyped extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) -> super(arguments...)
	validate: (val) -> isValid(val, @type)
	getTypeName: -> getTypeName(@type)
	# parent Type proxy, i.e. no proxy

export default Type.createHelper(Untyped)
