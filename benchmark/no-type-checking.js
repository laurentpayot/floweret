const TIMES = 100 * 1000

console.log("\n*** No type-checking ***")

// example from https://codemix.github.io/flow-runtime/#/
function greet(person) {
	return 'Hello ' + person.name
}

console.time(TIMES + " greets")
for (let i = 0; i < TIMES; i++) {
	greet({ name: 'Alice' })
}
console.timeEnd(TIMES + " greets")


function f(a) {
	return a.reduce((acc, cur) => acc + cur)
}
const a = [...Array(100).keys()]

console.time(TIMES + " reductions")
for (let i = 0; i < TIMES; i++) {
	f(a)
}
console.timeEnd(TIMES + " reductions")
