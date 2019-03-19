// wrapping and assigning properties (.skip, .only etc.) to global Jest functions for use in CoffeeScript test files

// CS implicit return ≠ A "describe" callback must not return a value.
const describeJS = global.describe
global.describe = Object.assign((name, f) => describeJS(name, function () { f() }), describeJS)

// tests with CS `for` loops last statement ≠ `it` and `test` must return either a Promise or undefined.
const testJS = global.test
global.test = Object.assign((name, f) => testJS(name, function () {
	let result = f()
	return Array.isArray(result) ? undefined : result
}), testJS)

