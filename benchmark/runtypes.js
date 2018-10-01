const {	Number,	String,	Array, Record, Contract } = require('runtypes')

const TIMES = 100 * 1000

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
const a = [...global.Array(100).keys()]

console.time(TIMES + " sums")
for (let i = 0; i < TIMES; i++) {
	sum(a)
}
console.timeEnd(TIMES + " sums")
