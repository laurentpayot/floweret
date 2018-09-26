const { fn } = require('../dist')
const TIMES = 100 * 1000

console.log("\n*** Floweret ***")

// example from https://codemix.github.io/flow-runtime/#/
const Person = {name: String}
const greet = fn(
	[Person], String,
	function (person) {
		return 'Hello ' + person.name
	}
)

console.time(TIMES + " greets")
for (let i = 0; i < TIMES; i++) {
	greet({ name: 'Alice' })
}
console.timeEnd(TIMES + " greets")


const f = fn(
	[Array(Number)], Number,
	function (a) {
		return a.reduce((acc, cur) => acc + cur)
	}
)
const a = [...Array(100).keys()]

console.time(TIMES + " reductions")
for (let i = 0; i < TIMES; i++) {
	f(a)
}
console.timeEnd(TIMES + " reductions")
