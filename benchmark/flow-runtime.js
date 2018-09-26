const TIMES = 100 * 1000
const SIZE = 100
const t = require('flow-runtime')
let title = ""

console.log("\n*** Flow-runtime ***")

// example from https://codemix.github.io/flow-runtime/#/
const Person = t.type('Person', t.object(t.property('name', t.string())))
function greet(person) {
	let _personType = Person
	const _returnType = t.return(t.string())
	t.param('person', _personType).assert(person)
	return _returnType.assert('Hello ' + person.name)
}
t.annotate(greet, t.function(t.param('person', Person), t.return(t.string())))

title = `${TIMES} times greet`
console.time(title)
for (let i = 0; i < TIMES; i++) {
	greet({ name: 'Alice' })
}
console.timeEnd(title)


function f(a) {
	let _aType = t.array(t.number())
	const _returnType = t.return(t.number())
	t.param('a', _aType).assert(a)
	return _returnType.assert(a.length)
}
t.annotate(f, t.function(t.param('a', t.array(t.number())), t.return(t.number())))
const a = [...Array(SIZE).keys()]

title = `${TIMES} times ${SIZE} elements`
console.time(title)
for (let i = 0; i < TIMES; i++) {
	f(a)
}
console.timeEnd(title)
