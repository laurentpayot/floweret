export NATIVE_TYPES = [
	undefined, null, NaN, Infinity, -Infinity,
	Boolean, Number, String, Array, Date, Object, Function, Promise, Int8Array, Set, Map, Symbol
]

export VALUES = [
	undefined
	null
	NaN
	1.1
	0
	Infinity
	-Infinity
	true
	false
	""
	"a"
	" "
	"Énorme !"
	[]
	[1]
	[undefined]
	Array(1)
	Array(2)
	Array(3)
	[1, 'a', null, undefined]
	new Int8Array([1, 2])
	{}
	{foo: 'bar'}
	{name: 'Number'}
	{a: 1, b: {a: 2, b: null, c: '3'}}
	new Date()
	(->)
	new Promise(->)
	new Set([])
	new Set([1, 2])
	new Map([])
	new Map([[ 1, 'one' ], [ 2, 'two' ]])
	Symbol('foo')
]

export testTypes = (val, type) ->
	expect(isValid(val, type)).to.be.true
	expect(isValid(val, t)).to.be.false \
		for t in NATIVE_TYPES when not(t is type or Number.isNaN val and Number.isNaN type)
