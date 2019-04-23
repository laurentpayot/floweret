import Type from './Type'
import isValid from '../isValid'
import {getTypeName} from '../tools'

class Unchecked extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) -> super(arguments...)
	validate: (val) -> isValid(val, @type)
	getTypeName: -> getTypeName(@type)
	helperName: 'unchecked'
	# parent Type checkWrap, i.e. no checkWrap

export default Type.createHelper(Unchecked)
