# :blossom: Floweret

A runtime signature type-checker using native JavaScript types.

* **Simple**: Native JavaScript types syntax.
* **Lightweight**: 2 kb minified and gzipped. No dependencies.
* **Fast**: Direct type comparison. No string to parse.
* **Powerful**: Logical operators, tuples, regular expressions, rest parameters and more…
* **Customizable**: Create your own types for your own needs.

## Contents

* [Install](#install)
* [Usage](#usage)
  * [JavaScript](#javascript)
  * [CoffeeScript](#coffeescript)
* [Type syntax](#type-syntax)
  * [Absence of type](#absence-of-type)
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

> fn( <argument 1 type\>, <argument 2 type\>, …, <argument n type\>, <result type\>, <function\> )

To add a signature to a function, wrap the function with the `fn` function.
`fn` arguments are first the list of arguments types, followed by the result type, and finally the function itself:

### JavaScript

```js
import { fn } from 'floweret'

const add = fn(
  Number, Number, Number,
  function (a, b) {return a + b}
)
```

or using the ES2015 arrow function syntax:

```js
import { fn } from 'floweret'

const add = fn(
  Number, Number, Number,
  (a, b) => a + b
)
```

For readability, most examples below will use the ES2015 arrow function syntax.

### CoffeeScript

You can ommit the `fn` parentheses, resulting in a decorator-like syntax:

```coffee
# CoffeeScript
import { fn } from 'floweret'

add = fn Number, Number, Number,
  (a, b) -> a + b
```

## Type syntax

### Absence of type

Use `undefined` as the arguments types list when the functions takes no argument:

```js
const returnHi = fn(
  undefined, String,
  function () {return "Hello!"}
)

returnHi()  // Hello!
returnHi(1) // InvalidSignature: Too many arguments
```

Use `undefined` as well as the result type when the function returns nothing (undefined):

```js
const logInfo = fn(
  String, undefined
  function (msg) {console.log("Info:", msg)}
)

logInfo("Boo.") // logs "Info: Boo." but returns undefined
```

### Native types

> <native type\>

All native JavaScript type constructors are allowed as type:
`Number`, `String`, `Array`, `Object`, `Boolean`, `RegExp`, `undefined`, `null`, `Promise`, `Set`, `Map`, `WeakMap`, `WeakSet`, etc.

```js
const f = fn(
  Number, String, Array,
  (a, b) => [a, b]
)

f(1, 'a') // [1, 'a']
f(1, 5)   // TypeMismatch: Argument #2  should be of type 'String' instead of Number 5.
```

### Union of types

> [ <type 1\>, <type 2\>, …, <type n\> ]

You can create a type that is the union of several types. Simply put them between brackets.
For instance the type `[Number, String]` will accept a number or a string.

```js
const f = fn(
  Number, [Number, String], String,
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
import maybe from 'floweret/types/maybe'

const f = fn(
  Number, maybe(Number), Number,
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
  ['left', 'right'], String,
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
  Email, String, String, undefined,
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
  Array(String), String,
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
  Array(5), String,
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
  userType, String,
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
  {x: Number, y: Number}, Number,
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
import { fn } from 'floweret'
import promised from 'floweret/types/promised'
```

*Documentation in progress…*

### Any type wildcard

> []

or

> AnyType

```js
import { fn } from 'floweret'
import AnyType from 'floweret/types/AnyType'
```

*Documentation in progress…*

### Rest type

> etc(<type\>)

or (untyped)

> etc

```js
import { fn } from 'floweret'
import etc from 'floweret/types/etc'
```

* **:warning:** Rest type can only be the last type of the signature arguments types, [as it should be in JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters#Description).
* **:coffee:** CoffeeScript doesn't have this limitation, but this neat CoffeeScript feature is not implemented in floweret.

*Documentation in progress…*

### Logical operators

#### or

> or( <type 1\>, <type 2\>, …, <type n\> )

This is the same as putting types into brackets, but more explicit.

```js
import { fn } from 'floweret'
import or from 'floweret/types/or'
```

* **:coffee:** `or` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import Or from 'floweret/types/or'
  ```

*Documentation in progress…*

#### and

> and( <type 1\>, <type 2\>, …, <type n\> )

```js
import { fn } from 'floweret'
import and from 'floweret/types/and'

const weeklyTotal = fn(
  and(Array(Number), Array(7)), Number,
  (days) => days.reduce((acc, curr) => acc + curr)
)

weeklyTotal([1, 1, 2, 2, 5, 5, 1]) // 17
weeklyTotal([1, 1, 2, 2, 5, 5]) // Argument #1 should be of type ''array of 'Number'' and 'array of 7 elements'' instead of Array.
```

* **:coffee:** `and` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import And from 'floweret/types/and'
  ```

*Documentation in progress…*

#### not

> not( <type\> )

```js
import { fn } from 'floweret'
import not from 'floweret/types/not'
```

* **:coffee:** `not` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import Not from 'floweret/types/not'
  ```

*Documentation in progress…*

### Tuple types

> Tuple( <type 1\>, <type 2\>, …, <type n\> )

```js
import { fn } from 'floweret'
import Tuple from 'floweret/types/Tuple'
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
Phone = [Number, undefined]
Name = {first: String, last: String, middle: [String, undefined]}
User = {id: Number, name: Name, phone: Phone}
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

The sub-benchmarks are run from minified Rollup bundles (UMD) with [two simple functions](https://github.com/laurentpayot/floweret/tree/master/benchmark). Feel free to make your own benchmarks.

```txt
no-type-checking-benchmark.min.js.gz  258 bytes
floweret-benchmark.min.js.gz          2323 bytes
runtypes.min.js.gz                    3030 bytes
flow-runtime-benchmark.min.js.gz      20233 bytes


*** No type-checking ***
10000 greets: 1.423ms
10000 sums: 17.827ms

*** Floweret ***
10000 greets: 14.278ms
10000 sums: 77.677ms

*** Runtypes ***
10000 greets: 12.674ms
10000 sums: 53.387ms

*** Flow-runtime ***
10000 greets: 174.898ms
10000 sums: 557.707ms
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
