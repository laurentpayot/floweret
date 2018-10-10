# typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for null, NaN, Promise etc.
typeOf = (val) ->
	if val in [undefined, null, Infinity, -Infinity] or Number.isNaN(val) then '' + val else val.constructor.name

export default typeOf
