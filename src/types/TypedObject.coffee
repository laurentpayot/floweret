import Type from './Type'
import isValid from '../isValid'
import {isAny, getTypeName} from '../tools'

class TypedObject extends Type
	# exactly 1 argument
	argsMin: 1
	argsMax: 1
	constructor: (@type) ->
		super(arguments...)
		Type.warn "Use 'Object' type instead of a #{@constructor.name} with values of any type." if isAny(@type)
	validate: (val) -> switch
		when val?.constructor isnt Object then false
		when isAny(@type) then true
		else Object.values(val).every((v) => isValid(v, @type))
	getTypeName: -> "object with values of type '#{getTypeName(@type)}'"
	checkWrap: (obj, context) ->
		#super(obj, context)
		# custom instantiation validation
		unless @validate(obj)
			super(obj, context) unless obj?.constructor is Object
			badObj = @checkWrap({}, context)
			(badObj[k] = v) for k, v of obj
		new Proxy(obj,
			set: (o, k, v) =>
				Type.error("#{if context then context+' ' else ''}object property '#{k}'", v, @type) unless isValid(v, @type)
				o[k] = v
				true # indicate success
		)

export default Type.createHelper(TypedObject)
