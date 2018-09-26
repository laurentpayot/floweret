const TIMES = 100 * 1000
const SIZE = 100
let title = ""

console.log("\n*** No type-checking ***")

// example from https://codemix.github.io/flow-runtime/#/
function greet(person) {
	return 'Hello ' + person.name
}

title = `${TIMES} times greet`
console.time(title)
for (let i = 0; i < TIMES; i++) {
	greet({ name: 'Alice' })
}
console.timeEnd(title)


function f(a) {
	return a.length
}
const a = [...Array(SIZE).keys()]

title = `${TIMES} times ${SIZE} elements`
console.time(title)
for (let i = 0; i < TIMES; i++) {
	f(a)
}
console.timeEnd(title)
