const TIMES = 100 * 1000
const SIZE = 100
const { fn } = require('../dist')
let title = ""

console.log("\n*** Floweret ***")

// example from https://codemix.github.io/flow-runtime/#/
const Person = {name: String}
const greet = fn(
	[Person], String,
	function (person) {
		return 'Hello ' + person.name
	}
)

title = `${TIMES} times greet`
console.time(title)
for (let i = 0; i < TIMES; i++) {
	greet({ name: 'Alice' })
}
console.timeEnd(title)


const f = fn(
	[Array(Number)], Number,
	function (a) {
		return a.length
	}
)
const a = [...Array(SIZE).keys()]

title = `${TIMES} times ${SIZE} elements`
console.time(title)
for (let i = 0; i < TIMES; i++) {
	f(a)
}
console.timeEnd(title)
