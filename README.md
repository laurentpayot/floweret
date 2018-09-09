
runtime-signature
=================

Type-checking for functions at runtime with native JavaScript types signatures.


Features
--------

* Super-simple native types syntax, highlighted by your editor of choice.
* Efficient: direct type evaluation, no string to parse.
* Lightweight: 5.9 kb minified, 2.2 kb minified and gzipped.
* No dependencies.

Install
-------

```bash
$ npm install runtime-signature
# or
$ yarn add runtime-signature
```

Usage
-----

> fn( [ <argument 1 type\>, <argument 2 type\>, …, <argument n type\> ], <result type\>, <function\> )

To add a signature to a function, wrap the function with the `fn` function.

### Javascript

```js
import { fn } from 'runtime-signature'

f = fn(
  [Number, Number], Number,
  function(a, b) {return a + b}
)
```
or using the ES2015 arrow function syntax:

```js
import { fn } from 'runtime-signature'

f = fn(
  [Number, Number], Number,
  (a, b) => a + b
)
```

### CoffeeScript

You can ommit the `fn` parentheses, resulting in a decorator-like syntax:

```coffee
import { fn } from 'runtime-signature'

f = fn [Number, Number], Number,
    (a, b) -> a + b
```

Type syntax
-----------

For readability, all examples below will use the ES2015 arrow function syntax.

### Native types

> <native type\>

All native JavaScript type constructors are allowed as type:
`Number`, `String`, `Array`, `Object`, `Boolean`, `undefined`, `null`, `Promise`, `Set`, `Map`, `WeakMap`, `WeakSet`, etc.

```js
f = fn(
  [Number, String], Boolean,
  (a, b) => a + b === '1a'
)

f(1, 'a') // true
f(1, 5)   // Error: Argument number 2 (5) should be of type String instead of Number.
```

### Union of types

> [ <type 1\>, <type 2\>, … , <type n\> ]

You can create a type that is the union of several types. Simply put them in a list.
For instance the type `[Number, String]` will accept a number or a string.

```js
f = fn(
  [Number, [Number, String]], String,
  (a, b) => '' + a + b
)

f(1, 2)    // '12'
f(1, '2')  // '12'
f(1, true) // Type error: Argument number 2 (true) should be of type Number or String instead of Boolean.
```

### Maybe type

> maybe( <type\> )

This is simply a shortcut to the union `[undefined, null, <type>]`. Usefull for optional parameters of a function.

```js
import { fn, maybe } from 'runtime-signature'

f = fn(
  [Number, maybe(Number)], Number,
  (a, b=0) => a + b
)

f(5)      // 5
f(5, 1)   // 6
f(5, '1') // Type error: Argument number 2 (1) should be of type undefined or null or Number instead of String.
```

### Literal type

> <string or number or boolean\>

Literals can only be strings, numbers or booleans. Literal are useful when used inside an union list.

```js
f = fn(
  [['development', 'production']], Boolean,
  (mode) => process.env.NODE_ENV === mode
)

f('production') // true or false
f('staging')    // Type error: Argument number 1 (staging) should be literal 'development' or literal 'production' instead of String.
```

### Typed Array

> Array(<type\>)

You can use the `Array` type for arrays with elements of any type, but most of the time it is better to specify the type of the elements.

Simply use `Array(Number)` for an array of number.

:warning: If you want an array with elements of a type that is the union of severay types, do not forget the brackets (`[` and `]`). Use `Array([Number, String])` to accept an array of elements that can be numbers or strings, such as `[1, "2", 3]`.
If you forget the brackets you will get the union of types instead of the array of union of types, because in JavaScript `Array(Number, String)` is the same as `[Number, String]`.

*Documentation in progress…*

### Object type

> {<key 1\>: <type 1\>, <key 2\>: <type 2\>, … , <key n\>: <type n\>}

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
    first: "Robert"
    last: "Smith"
  }
}

fullName(Bob)        // "Robert Smith"
fullName({id: 1234}) // Type error: Argument number 1 ([object Object]) should be of type custom type object instead of Object.
```

:warning: If values of an object argument match all the keys types of the object type, **the argument will be accepted even if it has more keys than the object type**:

```js
f = fn(
  [{x: Number, y: Number}], Number,
  (coords) => coords.x + 2 * coords.y
)

f({x: 1, y: 2})             // 5
f({x: 1, y: 2, foo: "bar"}) // 5 (no error)
```

### Custom class type

> <custom class\>

*Documentation in progress…*

### Promise type

> Promise.resolve(<type\>)

or

> promised(<type\>)

Promised types are used for the *result type* of the function signature.

You can use the `Promise` type for promises that resolve with a value of any type, but most of the time it is better to specify the type of the resolved value.

For instance use `Promise.resolve([Object, null])` for a promise that will resolve with an object or the null value.

```js
import { fn, promised } from 'runtime-signature'
```

*Documentation in progress…*

### Any type wildcard

> []

or

> anyType

```js
import { fn, anyType } from 'runtime-signature'
```

*Documentation in progress…*

### Rest type

> etc(<type\>)

or (untyped)

> etc

:warning: Rest type can only be the last type of the signature arguments types, [as it should be in JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters#Description).
CoffeeScript doesn't have this limitation, but this neat CoffeeScript feature is not implemented in runtime-signature.

```js
import { fn, etc } from 'runtime-signature'
```

*Documentation in progress…*

### Typed Object

> typedObject(<values type\>)

*Documentation in progress…*

### Typed Set

> typedSet(<elements type\>)

*Documentation in progress…*

### Typed Map

> typedMap(<values type\>)

or

> typedMap(<keys type\>, <values type\>)

*Documentation in progress…*

Type composition
----------------

As the types are simply JavaScript expressions, you can assign any type to a variable and use it to create new types.

```js
phoneType = [Number, undefined]
nameType = {first: String, last: String, middle: [String, undefined]}
userType = {id: Number, name: nameType, phone: phoneType}
```

Type tools
----------

Some handy utilities exported by the package.

### isType

> isType(<value\>, <type\>)

```js
isType("abc", [Number, String]) // true
```

### TypeOf

> typeOf(<value\>)

```js
// standard JavaScript `typeof` keyword
typeof [1, 2] // 'object'
typeof Promise.resolve(1) // 'object'

// more usefull results
typeOf([1, 2]) // 'Array'
typeOf(Promise.resolve(1)) // 'Promise'
```

Features to come
----------------

* `fn` as a decorator, [when JavaScript decorators reaches stage 4 and are implemented in CoffeeScript](https://github.com/jashkenas/coffeescript/issues/4917#issuecomment-387220758).

Licence
-------

MIT
