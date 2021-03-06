import t from 'flow-runtime'

const TIMES = 10 * 1000

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

console.time(TIMES + " greets")
for (let i = 0; i < TIMES; i++) {
	let alice = { name: 'alice' }
	Person.assert(alice)
	alice.name = 'Alice'
	Person.assert(alice)
	greet(alice)
}
console.timeEnd(TIMES + " greets")


function sum(a) {
	let _aType = t.array(t.number())
	const _returnType = t.return(t.number())
	t.param('a', _aType).assert(a)
	a[0] = -100
	t.number().assert(a[0]) // element type has to be checked manually
	return _returnType.assert(a.reduce((acc, curr) => acc + curr))
}
t.annotate(sum, t.function(t.param('a', t.array(t.number())), t.return(t.number())))

console.time(TIMES + " sums")
for (let i = 0; i < TIMES; i++) {
	sum([...Array(100).keys()])
}
console.timeEnd(TIMES + " sums")
