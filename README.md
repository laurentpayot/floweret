# :blossom: Floweret

A [2 kB, fast](#benchmark), runtime type-checker with Flow-*like* features.

## Contents

* [Install](#install)
* [Usage](#usage)
  * [JavaScript](#javascript)
  * [CoffeeScript](#coffeescript)
* [Type syntax](#type-syntax)
  * [Native types](#native-types)
  * [Union of types](#union-of-types)
  * [Maybe type](#maybe-type)
  * [Literal type](#literal-type)
  * [Regular Expressions](#regular-expressions)
  * [Typed Array](#typed-array)
  * [Sized Array](#sized-array)
  * [Object type](#object-type)
  * [Class type](#class-type)
  * [Promise type](#promise-type)
  * [Any type wildcard](#any-type-wildcard)
  * [Rest type](#rest-type)
  * [Logical operators](#logical-operators)
    * [or](#or)
    * [and](#and)
    * [not](#not)
  * [Tuple types](#tuple-types)
  * [Typed Object](#typed-object)
  * [Typed Set](#typed-set)
  * [Typed Map](#typed-map)
* [Type composition](#type-composition)
* [Custom types](#custom-types)
* [Type tools](#type-tools)
  * [isType](#istype)
  * [typeOf](#typeof)
* [Features to come](#features-to-come)
* [Benchmark](#benchmark)
* [License](#license)

## Install

```bash
$ npm install floweret
# or
$ yarn add floweret
```

## Usage

> fn( [ <argument 1 type\>, <argument 2 type\>, …, <argument n type\> ], <result type\>, <function\> )

To add a signature to a function, wrap the function with the `fn` function.
`fn` arguments are first the *array* of input types, followed by the result type, and finally the function itself:

### JavaScript

```js
import { fn } from 'floweret'

const add = fn(
  [Number, Number], Number,
  function (a, b) {return a + b}
)
```

or using the ES2015 arrow function syntax:

```js
import { fn } from 'floweret'

const add = fn(
  [Number, Number], Number,
  (a, b) => a + b
)
```

### CoffeeScript

You can ommit the `fn` parentheses, resulting in a decorator-like syntax:

```coffee
# CoffeeScript
import { fn } from 'floweret'

add = fn [Number, Number], Number,
  (a, b) -> a + b
```

## Type syntax

For readability, all examples below will use the ES2015 arrow function syntax.

### Native types

> <native type\>

All native JavaScript type constructors are allowed as type:
`Number`, `String`, `Array`, `Object`, `Boolean`, `RegExp`, `undefined`, `null`, `Promise`, `Set`, `Map`, `WeakMap`, `WeakSet`, etc.

```js
const f = fn(
  [Number, String], Array,
  (a, b) => [a, b]
)

f(1, 'a') // [1, 'a']
f(1, 5)   // TypeMismatch: Argument #2  should be of type 'String' instead of Number 5.
```

### Union of types

> [ <type 1\>, <type 2\>, …, <type n\> ]

You can create a type that is the union of several types. Simply put them in a list.
For instance the type `[Number, String]` will accept a number or a string.

```js
const f = fn(
  [Number, [Number, String]], String,
  (a, b) => '' + a + b
)

f(1, 2)    // '12'
f(1, '2')  // '12'
f(1, true) // TypeMismatch: Argument #2 should be of type 'Number or String' instead of Boolean true.
```

### Maybe type

> maybe( <type\> )

This is simply a shortcut to the union `[undefined, null, <type>]`. Usefull for optional parameters of a function.

```js
import { fn } from 'floweret'
import maybe from 'floweret/maybe'

const f = fn(
  [Number, maybe(Number)], Number,
  (a, b=0) => a + b
)

f(5)      // 5
f(5, 1)   // 6
f(5, '1') // TypeMismatch: Argument #2  should be of type 'undefined or null or Number' instead of String "1".
```

### Literal type

> <string or number or boolean or undefined or null or NaN\>

A literal can only be a string, a number, a boolean or be equal to `undefined` or `null` or `NaN`. Literals are useful when used inside an union list.

```js
const turn = fn(
  [['left', 'right']], String,
  (direction) => "turning " + direction
)

turn('left')  // "turning left"
turn('light') // TypeMismatch: Argument #1 should be of type 'literal String "left" or literal String "right"' instead of String "light".
```

### Regular Expressions

> <regular expression\>

When the type is a regular expression, if the value is a string it will be tested to see if it matches the regular expression.

* **:warning:** Regular expressions are slow so if you need to check a lot of data consider creating a custom type (see below) with a `validate` method using String prototype methods instead.

```js
const Email = /\S+@\S+\.\S+/ // simple email RegExp, do not use in production

const showEmail = fn(
  [Email, String, String], undefined,
  (email, subject, content) => console.table({ email, subject, content })
)

// nice email display
showEmail('laurent@example.com', "Hi", "Hello!")

// TypeMismatch: Argument #1 should be of type 'string matching regular expression /\S+@\S+\.\S+/' instead of String "laurent.example.com".
showEmail('laurent.example.com', "Hi", "Hello!")
```

### Typed Array

> Array(<type\>)

You can use the `Array` constructor type for arrays with elements of any type, but most of the time it is better to specify the type of the elements.

If you want to specify the type of the elements of an array, use this type as the `Array` constructor argument. For instance simply use `Array(String)` for an array of strings:

```js
const dashJoin = fn(
  [Array(String)], String,
  (strings) => strings.join('-')
)

dashJoin(["a", "b", "c"]) // a-b-c
dashJoin(["a", "b", 3])   // Argument #1 should be an array with element 2 of type 'String' instead of Number 3.
```

* **:warning:** If you want an array with elements of a type that is the union of severay types, do not forget the brackets (`[` and `]`).
  * Use `Array([Number, String])` to accept an array of elements that can be numbers or strings, such as `[1, "2", 3]`.
  * If you forget the brackets you will get the union of types instead of the array of union of types, because in JavaScript `Array(Number, String)` is the same as `[Number, String]`.

### Sized Array

> Array(<length\>)

If you want to specify the length of an array, use this length as the `Array` constructor argument.

For instance use `Array(5)` for an array of five elements:

```js
const pokerHand = fn(
  [Array(5)], String,
  (cards) => cards.join('-')
)

pokerHand([7, 9, "Q", "K", 1])     // 7-9-Q-K-1
pokerHand([7, 9, 10, "Q", "K", 1]) // TypeMismatch: Argument #1 should be an array with a length of 5 instead of 6.
```

Sized array type is useful when used in conjunction with a typed array type, thanks to the [`and` operator](#and).

### Object type

> {<key 1\>: <type 1\>, <key 2\>: <type 2\>, …, <key n\>: <type n\>}

You can specify the types of an object values, at any depth.

```js
userType = {
  id: Number,
  name: {
    first: String,
    last: String,
    middle: [String, undefined]
  }
}

fullName = fn(
  [userType], String,
  (user) => Object.keys(user.name).join(' ')
)

Bob = {
  id: 1234,
  name: {
    first: "Robert",
    last: "Smith"
  }
}

// "Robert Smith"
fullName(Bob)

// TypeMismatch: Argument #1 should be an object with key 'name.first' of type 'String' instead of Number 1.
fullName({id: 1234, name: {first: 1, last: "Smith"}})
```

* **:warning:** If values of an object argument match all the keys types of the object type, **the argument will be accepted even if it has more keys than the object type**:

```js
f = fn(
  [{x: Number, y: Number}], Number,
  (coords) => coords.x + 2 * coords.y
)

f({x: 1, y: 2})             // 5
f({x: 1, y: 2, foo: "bar"}) // 5 (no error)
```

### Class type

> <class\>

*Documentation in progress…*

### Promise type

> Promise.resolve(<type\>)

or

> promised(<type\>)

Promised types are used for the *result type* of the function signature.

You can use the `Promise` type for promises that resolve with a value of any type, but most of the time it is better to specify the type of the resolved value.

For instance use `Promise.resolve([Object, null])` for a promise that will resolve with an object or the null value.

```js
import promised from 'floweret/promised'
```

*Documentation in progress…*

### Any type wildcard

> []

or

> AnyType

```js
import AnyType from 'floweret/AnyType'
```

*Documentation in progress…*

### Rest type

> etc(<type\>)

or (untyped)

> etc

```js
import etc from 'floweret/etc'
```

* **:warning:** Rest type can only be the last type of the signature arguments types, [as it should be in JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters#Description).
* **:coffee:** CoffeeScript doesn't have this limitation, but this neat CoffeeScript feature is not implemented in floweret.

*Documentation in progress…*

### Logical operators

#### or

> or( <type 1\>, <type 2\>, …, <type n\> )

This is the same as putting types into brackets, but more explicit.

```js
import or from 'floweret/or'
```

* **:coffee:** `or` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import Or from 'floweret/or'
  ```

*Documentation in progress…*

#### and

> and( <type 1\>, <type 2\>, …, <type n\> )

```js
import and from 'floweret/and'

const weeklyTotal = fn(
  [and(Array(Number), Array(7))], Number,
  (days) => days.reduce((acc, curr) => acc + curr)
)

weeklyTotal([1, 1, 2, 2, 5, 5, 1]) // 17
weeklyTotal([1, 1, 2, 2, 5, 5]) // Argument #1 should be of type ''array of 'Number'' and 'array of 7 elements'' instead of Array.
```

* **:coffee:** `and` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import And from 'floweret/and'
  ```

*Documentation in progress…*

#### not

> not( <type\> )

```js
import not from 'floweret/not'
```

* **:coffee:** `not` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import Not from 'floweret/not'
  ```

*Documentation in progress…*

### Tuple types

> Tuple( <type 1\>, <type 2\>, …, <type n\> )

```js
import Tuple from 'floweret/Tuple'
```

*Documentation in progress…*

### Typed Object

> TypedObject(<values type\>)

*Documentation in progress…*

### Typed Set

> TypedSet(<elements type\>)

*Documentation in progress…*

### Typed Map

> TypedMap(<values type\>)

or

> TypedMap(<keys type\>, <values type\>)

*Documentation in progress…*

## Type composition

As the types are simply JavaScript expressions, you can assign any type to a variable and use it to create new types.

```js
phoneType = [Number, undefined]
nameType = {first: String, last: String, middle: [String, undefined]}
userType = {id: Number, name: nameType, phone: phoneType}
```

## Custom types

*Documentation in progress…*

## Type tools

Some handy utilities exported by the package.

### isType

> isType(<value\>, <type\>)

```js
isType("abc", [Number, String]) // true
```

### typeOf

> typeOf(<value\>)

```js
// standard JavaScript `typeof` keyword
typeof [1, 2] // 'object'
typeof Promise.resolve(1) // 'object'

// more usefull results
typeOf([1, 2]) // 'Array'
typeOf(Promise.resolve(1)) // 'Promise'
```

## Features to come

* `fn` as a decorator, when JavaScript decorators reach stage 4.

## Benchmark

Run the benchmark with:

```shell
npm run benchmark
```

The sub-benchmarks are run from minified Rollup bundles (UMD) with [two simple functions](https://github.com/laurentpayot/floweret/tree/master/benchmark). Feel free to make your own benchmarks

```txt
floweret-benchmark.min.js.gz          2358 bytes
flow-runtime-benchmark.min.js.gz      21133 bytes
no-type-checking-benchmark.min.js.gz  287 bytes

*** No type-checking ***
100000 greets: 3.447ms
100000 sums: 36.097ms

*** Floweret ***
100000 greets: 33.274ms
100000 sums: 448.260ms

*** Flow-runtime ***
100000 greets: 1099.640ms
100000 sums: 4623.753ms
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
