import { Number, String, Array, Record, Contract } from 'runtypes'

const TIMES = 10 * 1000

console.log("\n*** Runtypes ***")

// example from https://codemix.github.io/flow-runtime/#/
const Person = Record({
	name: String
})
const greet = Contract(
	Person,
	String
).enforce(
	function (person) {
		return 'Hello ' + person.name
	}
)

console.time(TIMES + " greets")
for (let i = 0; i < TIMES; i++) {
	let alice = Person.check({ name: 'alice' })
	alice.name = 'Alice'
	greet(alice)
}
console.timeEnd(TIMES + " greets")


const sum = Contract(
	Array(Number),
	Number
).enforce(
	function (a) {
		a[0] = Number.check(-100) // element type has to be checked manually
		return a.reduce((acc, curr) => acc + curr)
	}
)

console.time(TIMES + " sums")
for (let i = 0; i < TIMES; i++) {
	sum([...global.Array(100).keys()])
}
console.timeEnd(TIMES + " sums")
