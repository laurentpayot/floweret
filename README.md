# :blossom: Floweret

[![Build Status](https://travis-ci.org/laurentpayot/floweret.svg?branch=master)](https://travis-ci.org/laurentpayot/floweret)
[![Coverage Status](https://coveralls.io/repos/github/laurentpayot/floweret/badge.svg?branch=master)](https://coveralls.io/github/laurentpayot/floweret?branch=master)
[![npm version](https://img.shields.io/npm/v/floweret.svg)](https://www.npmjs.com/package/floweret)

Floweret is a JavasScrit *runtime* signature type checker that is:

* **Simple**: Native JavaScript types syntax.
* **Lightweight**: 2.4 kb minified and gzipped. No dependencies.
* **Fast**: Direct type comparison. No string to parse.
* **Powerful**: Type composition, promises, rest parameters, logical operators and more…
* **Customizable**: Create your own types for your own needs.

## Contents

* [Install](#install)
* [Usage](#usage)
  * [JavaScript](#javascript)
  * [CoffeeScript](#coffeescript)
* [Type syntax](#type-syntax)
  * [Native types](#native-types)
  * [Absence of type](#absence-of-type)
  * [Union of types](#union-of-types)
  * [Maybe type](#maybe-type)
  * [Literal type](#literal-type)
  * [Regular expression type](#regular-expression-type)
  * [Typed array type](#typed-array-type)
  * [Sized array type](#sized-array-type)
  * [Object type](#object-type)
  * [Class type](#class-type)
  * [Promised type](#promised-type)
  * [Any type](#any-type)
  * [Rest arguments type](#rest-arguments-type)
  * [Logical operators](#logical-operators)
    * [Or](#or)
    * [And](#and)
    * [Not](#not)
  * [Constraint type](#constraint-type)
  * [Included types](#included-types)
    * [Tuple](#tuple)
    * [Typed Object](#typed-object)
    * [Typed Set](#typed-set)
    * [Typed Map](#typed-map)
    * [Integer](#integer)
    * [Natural](#natural)
    * [Sized string](#sized-string)
* [Type composition](#type-composition)
* [Custom types](#custom-types)
* [Type tools](#type-tools)
  * [isValid](#isvalid)
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

The following [CoffeeScript's type annotations example](https://coffeescript.org/#type-annotations) (that needs Flow in the background)

```coffee
# @flow

###::
type Obj = {
  num: number,
};
###

f = (str ###: string ###, obj ###: Obj ###) ###: string ### ->
  str + obj.num
```

can be rewritten with less "noise":

```coffee
import { fn } from 'floweret'

Obj =
  num: Number

f = fn String, Obj, String,
  (str, obj) ->
    str + obj.num
```

## Type syntax

### Native types

> <native type\>

All native JavaScript type constructors are allowed as type:
`Number`, `String`, `Array`, `Object`, `Boolean`, `RegExp`, `undefined`, `null`, `Promise`, `Function`, `Set`, `Map`, `WeakMap`, `WeakSet`, etc.

```js
const f = fn(
  Number, String, Array,
  (a, b) => [a, b]
)

f(1, 'a') // [1, 'a']
f(1, 5)   // TypeMismatch: Argument #2  should be of type 'String' instead of Number 5.
```

### Absence of type

When the function takes no argument, only the result type is needed:

```js
const returnHi = fn(
  String,
  function () {return "Hi"}
)

returnHi()  // Hi
returnHi(1) // TypeMismatch: Too many arguments provided.
```

Use `undefined` as the result type when the function returns nothing (undefined):

```js
const logInfo = fn(
  String, undefined
  function (msg) {console.log("Info:", msg)}
)

logInfo("Boo.") // logs "Info: Boo.", returns undefined

const logHi = fn(
  undefined
  function () {console.log("Hi")}
)

logHi() // logs "Hi", returns undefined
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
import { fn, maybe } from 'floweret'

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

### Regular Expression type

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

### Typed array type

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

### Sized array type

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
Note that you can use the empty array `[]` for an array of size 0 type, if you ever need it.

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

* **:warning:** If values of an object argument match all the keys types of the object type, **the argument will be accepted even if it has more keys than the object type** (except if type is the empty object `{}`):

```js
f = fn(
  {a: Boolean, b: {x: Number, y: Number}}, Number,
  (obj) => obj.b.x + obj.b.y
)

f({a: true, b: {x: 1, y: 2}}) // 3
f({a: true, b: {x: 1, y: 2}, foo: "bar"}) // 3 (no error)
f({a: true, b: {x: 1, z: 2}}) // TypeMismatch: Argument #1 should be an object with key 'b.y' of type 'Number' instead of missing key 'y'.
f({a: true, b: {x: 1, y: undefined}}) // TypeMismatch: Argument #1 should be an object with key 'b.y' of type 'Number' instead of undefined.
```

### Class type

> <class\>

Simply use the class itself as the type:

```js
class Rectangle {
  constructor(height, width) {
    this.height = height;
    this.width = width;
  }
}

// Of course it would be better to have superficy() as a Rectangle method,
// but that is not the point…
let superficy = fn(
  Rectangle, Number,
  (rect) => rect.height * rect.width
)

let myRect = new Rectangle(10, 5)

superficy(myRect) // 50
superficy("foo") // TypeMismatch: Argument #1 should be of type 'Rectangle' instead of String "foo".
superficy({height: 10, width: 5}) // TypeMismatch: Argument #1 should be of type 'Rectangle' instead of Object.
```

### Promised type

> Promise.resolve(<type\>)

or with the `promised` shortcut:

> import promised from 'floweret/types/promised'
>
> promised(<type\>)

Promised types are used for the *result* type of the function signature.

You can use the `Promise` result type when a function returns a promise that can be of any type, but most of the time it is better to specify the type of the resolved value.

For instance use the `Promise.resolve([Object, null])` type for a promise that will resolve with an object or the null value:

```js
const getUserById = fn(
  Number, Promise.resolve([Object, null]),
  function (id) {
    return new Promise(resolve => {
      // simulating slow database/network access
      setTimeout(() => id ? resolve({id, name: "Bob"}) : resolve("anonymous"), 1000)
    })
  }
)

await getUserById(1234) // {id: 1234, name: "Bob"}
await getUserById(0) // TypeMismatch: Result should be a promise of type 'Object or null' instead of String "anonymous".
```

### Any type

> Any

Use the `Any` type when a parameter or a result can be of any type:

```js
import { fn, Any } from 'floweret'

const log = fn(
  Any, undefined,
  (x) => console.log(x)
)

log("foo") // logs "foo"
log({a: 1, b: 2}) // logs Object {a: 1, b: 2}
```

### Rest arguments type

> etc(<type\>)

or (untyped)

> etc

```js
import { fn, etc } from 'floweret'

const average = fn(
  etc(Number), [Number, NaN], // for Floweret NaN is NOT a Number (unlike JavaScript)
  (...numbers) => numbers.reduce((acc, curr) => acc + curr, 0) / numbers.length
)

average()           // NaN (0/0)
average(2, 6, 4)    // 4
average([2, 6, 4])  // TypeMismatch: Argument #1 should be of type 'Number' instead of Array.
average(2, true, 4) // TypeMismatch: Argument #2 should be of type 'Number' instead of Boolean true.
```

* **:warning:** Rest type can only be the last type of the signature arguments types, [as it should be in JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters#Description).
* **:coffee:** CoffeeScript doesn't have this limitation, but this neat CoffeeScript feature is not implemented (yet) in floweret.

### Logical operators

#### Or

> or( <type 1\>, <type 2\>, …, <type n\> )

`or` is the same as the [union of types](#union-of-types) brackets notation, but more explicit.

```js
import { fn } from 'floweret'
import or from 'floweret/types/or'

const size = fn(
  or(String, Array), Number,
  (x) => x.length
)

size("ab")       // 2
size(['a', 'b']) // 2
size({a: 'b'})   // TypeMismatch: Argument #1 should be of type 'String or Array' instead of Object.
```

* **:coffee:** `or` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import Or from 'floweret/types/or'
  ```

#### And

> and( <type 1\>, <type 2\>, …, <type n\> )

`and` is for intersection of types. It is useful with constraints or to specify typed arrays of a given length:

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

#### Not

> not( <type\> )

`not` is the the complement type, i. e. for items not matching the type:

```js
import { fn } from 'floweret'
import not from 'floweret/types/not'

const getConstructor = fn(
  not([undefined, null]), Function,
  (x) => x.constructor
)

getConstructor(1)    // function Number()
getConstructor(null) // TypeMismatch: Argument #1 should be of type 'not 'undefined or null'' instead of null.
```

* **:coffee:** `not` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import Not from 'floweret/types/not'
  ```

### Constraint type

> constraint(<function\>)

You can quickly create new types using the `constraint` type, that takes a validation function as argument:

```js
import { fn } from 'floweret'
import constraint from 'floweret/types/constraint'

Int = constraint(val => Number.isInteger(val))

f = fn(
  Int, String,
  n => n + "eggs needed for that recipe"
)

f(2)   // "2 eggs needed for that recipe"
f(2.5) // TypeMismatch: Argument #1 should be of type 'constrained by 'val => Number.isInteger(val)'' instead of Number 2.5.
```

If you need more complex types have a look in the [Floweret-included types](#included-types) or create you own [custom types](#custom-types).

### Included types

#### Tuple

> Tuple( <type 1\>, <type 2\>, …, <type n\> )

```js
import { fn } from 'floweret'
import Tuple from 'floweret/types/Tuple'

Coords = Tuple(Number, Number, Number) // latitude, longitude, altitude

getLongitude = fn(
  Coords, Number,
  (c) => c[1]
)

getLongitude([10, 20, 5])   // 20
getLongitude([10, 5])       // TypeMismatch: Argument #1 should be of type 'tuple of 3 elements 'Number, Number, Number'' instead of Array.
getLongitude([10, 20, '5']) // TypeMismatch: Argument #1 should be of type 'tuple of 3 elements 'Number, Number, Number'' instead of Array.
```

#### Typed Object

> TypedObject(<values type\>)

```js
import { fn } from 'floweret'
import Tuple from 'floweret/types/Tuple'

Grades = TypedObject(Number)

maxGrade = fn(
  Grades, Number,
  (grades) => Math.max(...Object.values(grades))
)

maxGrade({
    Alice: 8,
    Larry: 8,
    Bob: 9
}) // 9

maxGrade({
    Alice: 8,
    Larry: "B",
    Bob: 9
}) // TypeMismatch: Argument #1 should be of type 'object with values of type 'Number'' instead of Object.
```

#### Typed Set

> TypedSet(<elements type\>)

*Documentation in progress…*

#### Typed Map

> TypedMap(<values type\>)

or

> TypedMap(<keys type\>, <values type\>)

*Documentation in progress…*

#### Integer

> Integer(<maximum value\>)

or

> Integer(<minimum value\>, <maximum value\>)

*Documentation in progress…*

#### Natural

> Natural(<maximum value\>)

or

> Natural(<minimum value\>, <maximum value\>)

*Documentation in progress…*

#### Sized string

> SizedString(<maximum length\>)

or

> SizedString(<minimum length\>, <maximum length\>)

## Type composition

As types are simply JavaScript expressions, you can assign any type to a variable and use it to create new types:

```js
const Phone = [Number, undefined]
const Name = {first: String, last: String, middle: [String, undefined]}
const User = {id: Number, name: Name, phone: Phone}
```

## Custom types

*Documentation in progress…*

## Type tools

Some handy utilities exported by the package.

### isValid

> isValid(<value\>, <type\>)

`isValid` can tell if a value is of a given type. Useful for user input validation:

```js
import { isValid } from 'floweret'

isValid("abc", [Number, String]) // true
```

### typeOf

> typeOf(<value\>)

The `typeOf` function is a replacement of the standard JavaScript `typeof` operator:

```js
import { typeOf } from 'floweret'

// standard JavaScript `typeof` operator
typeof [1, 2] // 'object'
typeof Promise.resolve(1) // 'object'
typeof NaN // 'number'

// more usefull results
typeOf([1, 2]) // 'Array'
typeOf(Promise.resolve(1)) // 'Promise'
typeOf(NaN) // 'NaN'
```

## Features to come

* `fn` as a decorator, when JavaScript decorators reach stage 4.

## Benchmark

Run the benchmark with:

```shell
npm run benchmark
```

The benchmark currently includes the folowing runtime type-checking systems:

* **no type-checking**: the reference results.
* [**Floweret**](https://github.com/laurentpayot/floweret): you might know it if you are reading this.
* [**Runtypes**](https://github.com/pelotom/runtypes): "Runtime validation for static types" (TypeScript-oriented)
* [**Flow-runtime**](https://codemix.github.io/flow-runtime): "Flow-compatible runtime type system for JavaScript."

The [sub-benchmarks](https://github.com/laurentpayot/floweret/tree/master/benchmark) are run from minified [Rollup](https://rollupjs.org) bundles (UMD) and call two simple functions several thousand times.

Here are some results from a machine that scores around 21000 to the [Octane 2.0](https://chromium.github.io/octane/) JavaScript benchmark:

```txt
no-type-checking-benchmark.min.js.gz  258 bytes
floweret-benchmark.min.js.gz          2736 bytes
runtypes.min.js.gz                    3030 bytes
flow-runtime-benchmark.min.js.gz      20233 bytes


*** No type-checking ***
10000 greets: 1.442ms
10000 sums: 17.552ms

*** Floweret ***
10000 greets: 16.193ms
10000 sums: 56.540ms

*** Runtypes ***
10000 greets: 12.570ms
10000 sums: 41.465ms

*** Flow-runtime ***
10000 greets: 167.345ms
10000 sums: 544.452ms
```

Feel free to make your own benchmarks and share the results.

## License

[MIT](https://choosealicense.com/licenses/mit/)
