:blossom: Floweret
==================

Runtime type-checking for everyone.


Features
--------

* **Easy**: Native Javascript types. No need for Babel.
* **Lightweight**: 2 kb minified and gzipped. No dependencies. Does not bloat your build with type-checking functions calls everywhere.
* **Efficient**: Direct type comparison, no string to parse. 10 times faster than [Flow-runtime](https://codemix.github.io/flow-runtime/#/).
* **Powerfull**: Logical operators, tuples, regular expressions, rest parameters and more…
* **Customizable**: Create your own types for your own needs.

Install
-------

```bash
$ npm install floweret
# or
$ yarn add floweret
```

Usage
-----

> fn( [ <argument 1 type\>, <argument 2 type\>, …, <argument n type\> ], <result type\>, <function\> )

To add a signature to a function, wrap the function with the `fn` function.
`fn` arguments are first the *array* of input types, followed by the result type, and finally the function itself:

### Javascript

```js
import { fn } from 'floweret'

add = fn(
  [Number, Number], Number,
  function (a, b) {return a + b}
)
```
or using the ES2015 arrow function syntax:

```js
import { fn } from 'floweret'

add = fn(
  [Number, Number], Number,
  (a, b) => a + b
)
```

### CoffeeScript

You can ommit the `fn` parentheses, resulting in a decorator-like syntax:

```coffee
import { fn } from 'floweret'

add = fn [Number, Number], Number,
  (a, b) -> a + b
```

Type syntax
-----------

For readability, all examples below will use the ES2015 arrow function syntax.

### Native types

> <native type\>

All native JavaScript type constructors are allowed as type:
`Number`, `String`, `Array`, `Object`, `Boolean`, `RegExp`, `undefined`, `null`, `Promise`, `Set`, `Map`, `WeakMap`, `WeakSet`, etc.

```js
f = fn(
  [Number, String], Boolean,
  (a, b) => a + b === '1a'
)

f(1, 'a') // true
f(1, 5)   // Type error: Argument number 2 (5) should be of type String instead of Number.
```

### Union of types

> [ <type 1\>, <type 2\>, …, <type n\> ]

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
import { fn } from 'floweret'
import maybe from 'floweret/maybe'

f = fn(
  [Number, maybe(Number)], Number,
  (a, b=0) => a + b
)

f(5)      // 5
f(5, 1)   // 6
f(5, '1') // Type error: Argument number 2 (1) should be of type undefined or null or Number instead of String.
```

### Literal type

> <string or number or boolean or undefined or null or NaN\>

A literal can only be a string, a number, a booleans or be equal to undefined or null or NaN. Literals are useful when used inside an union list.

```js
f = fn(
  [['development', 'production']], Boolean,
  (mode) => process.env.NODE_ENV === mode
)

f('production') // true or false
f('staging')    // Type error: Argument number 1 (staging) should be literal 'development' or literal 'production' instead of String.
```

### Regular Expressions

> <regular expression\>

When the type is a regular expression, if the value is a string it will be tested to see if it matches the regular expression.

:warning: Regular expressions are slow so if you need to check a lot of data consider creating a custom type (see below) with a `validate` method using String prototype methods instead.

*Documentation in progress…*

### Typed Array

> Array(<type\>)

You can use the `Array` type for arrays with elements of any type, but most of the time it is better to specify the type of the elements.

Simply use `Array(Number)` for an array of number.

:warning: If you want an array with elements of a type that is the union of severay types, do not forget the brackets (`[` and `]`). Use `Array([Number, String])` to accept an array of elements that can be numbers or strings, such as `[1, "2", 3]`.
If you forget the brackets you will get the union of types instead of the array of union of types, because in JavaScript `Array(Number, String)` is the same as `[Number, String]`.

*Documentation in progress…*

### Sized Array

> Array(<length\>)

*Documentation in progress…*

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

// Type error: Argument number 1 should be an object with key 'name.first' of type String instead of Number.
fullName({id: 1234, name: {first: 1, last: "Smith"}})
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

:warning: Rest type can only be the last type of the signature arguments types, [as it should be in JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters#Description).
CoffeeScript doesn't have this limitation, but this neat CoffeeScript feature is not implemented in floweret.

```js
import etc from 'floweret/etc'
```

*Documentation in progress…*

### Logical operators

#### or

> or( <type 1\>, <type 2\>, …, <type n\> )

This is the same as putting types into brackets, but more explicit.

```js
import or from 'floweret/or'
```

*Documentation in progress…*

#### and

> and( <type 1\>, <type 2\>, …, <type n\> )

```js
import and from 'floweret/and'
```

*Documentation in progress…*

#### not

> not( <type\> )

```js
import not from 'floweret/not'
```

:warning: :coffee: `not` is a reserved CoffeeScript token.
Use another identifier to import the `not` operator in a CoffeeScript file:

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

Features to come
----------------

* `fn` as a decorator, [when JavaScript decorators reach stage 4 and are implemented in CoffeeScript](https://github.com/jashkenas/coffeescript/issues/4917#issuecomment-387220758).

Licence
-------

MIT
