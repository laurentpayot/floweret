import { FunctionModel, ObjectModel, ArrayModel } from "objectmodel"

const TIMES = 10 * 1000

console.log("\n*** Object Model ***")

// example from https://codemix.github.io/flow-runtime/#/
const Person = new ObjectModel({name: String})
const greet = FunctionModel(Person).return(String)(
	function (person) {
		return 'Hello ' + person.name
	}
)

console.time(TIMES + " greets")
for (let i = 0; i < TIMES; i++) {
	let alice = new Person({ name: 'alice' })
	alice.name = 'Alice'
	greet(alice)
}
console.timeEnd(TIMES + " greets")

const sum = FunctionModel(ArrayModel(Number)).return(Number)(
	function (a) {
		a[0] = -100
		return a.reduce((acc, curr) => acc + curr)
	}
)

console.time(TIMES + " sums")
for (let i = 0; i < TIMES; i++) {
	sum([...Array(100).keys()])
}
console.timeEnd(TIMES + " sums")
