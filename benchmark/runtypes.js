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
	greet({ name: 'Alice' })
}
console.timeEnd(TIMES + " greets")


const sum = Contract(
	Array(Number),
	Number
).enforce(
	function (a) {
		return a.reduce((acc, curr) => acc + curr)
	}
)

console.time(TIMES + " sums")
for (let i = 0; i < TIMES; i++) {
	sum([...global.Array(100).keys()])
}
console.timeEnd(TIMES + " sums")
