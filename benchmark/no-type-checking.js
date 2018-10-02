const TIMES = 10 * 1000

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


function sum(a) {
	return a.reduce((acc, curr) => acc + curr)
}

console.time(TIMES + " sums")
for (let i = 0; i < TIMES; i++) {
	sum([...Array(100).keys()])
}
console.timeEnd(TIMES + " sums")
