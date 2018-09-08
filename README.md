
runtime-signature
=================

Type-checking for functions at runtime with native JavaScript types signatures.


Features
--------

* Super-simple native types syntax, highlighted by your editor of choice.
* Efficient: direct type evaluation, no string to parse.
* Lightweight: 5.8 kb minified, 2.1 kb minified and gzipped.
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

> sig( [ <argument 1 type\>, <argument 2 type\>, …, <argument n type\> ], <result type\>, <function\> )

To add a signature to a function, wrap the function with the `sig` function.

### Javascript

```js
import { sig } from 'runtime-signature'

f = sig(
  [Number, Number], Number,
  function(a, b) {return a + b}
)
```
or using the ES2015 arrow function syntax:

```js
import { sig } from 'runtime-signature'

f = sig(
  [Number, Number], Number,
  (a, b) => a + b 
)
```

### CoffeeScript

You can ommit the `sig` parentheses, resulting in a decorator-like syntax:

```coffee
import { sig } from 'runtime-signature'

f = sig [Number, Number], Number,
    (a, b) -> a + b
```

**Note**: For readability, all examples below will use the ES2015 arrow function syntax.

Type syntax
-----------

### Native types

> <native type\>

All native JavaScript type constructors are allowed as type:
`Number`, `String`, `Array`, `Object`, `Boolean`, `undefined`, `null`, `Promise`, `Set`, `Map`, `WeakMap`, `WeakSet`, etc.

```js
import { sig } from 'runtime-signature'

f = sig(
  [Number, String], Boolean,
  (a, b) => a + b === '1a'  
)

f(1, 'a') // true
f(1, 5)   // Error: Argument number 2 (5) should be of type String instead of Number.
```

### Union of types

> [ <type 1\>, <type 2\>, … , <type n\> ]

You can create a type that is the union of several types. Simply put them in a list.
For instance the type `[Number, String]` will accept a number value or a string value value.

```js
import { sig } from 'runtime-signature'

f = sig(
  [Number, [Number, String]], String,
  (a, b) => '' + a + b
)

f(1, 2)    // '12'
f(1, '2')  // '12'
f(1, true) // Type error: Argument number 2 (true) should be of type Number or String instead of Boolean.
```

### Maybe type

> maybe( <type\> )

This is simply a shortcut to the union `[undefined, null, <type>]`. Usefull for optional parameters of a function:

```js
import { sig, maybe } from 'runtime-signature'

f = sig(
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
f = sig(
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

### Object type

> {<key 1\>: <type 1\>, <key 2\>: <type 2\>, … , <key n\>: <type n\>}

You can specify the types of an object values, at any depth.

For instance:

```js
{id: Number, name: {first: String, last: String, middle: [String, undefined]}}
```

### Custom type (class)

**TODO!**

### Promise type

> Promise.resolve(<type\>)

or the shortcut (don't forget to import it)

> promised(<type\>)

Promised types are usually used as the result type of the function signature.

You can use the `Promise` type for promises that resolve with a value of any type, but most of the time it is better to specify the type of the resolved value.

For instance use `Promise.resolve([Object, null])` for a promise that will resolve with an object or the null value.

### Any type wildcard

> []

### Rest type

> etc(<type\>)

:warning: Rest type can only be the last type of the signature arguments types, [as it should be in JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters#Description).
CoffeeScript doesn't have this limitation, but this neat CoffeeScript feature is not implemented in runtime-signature.

### Type composition

As the types are simply JavaScript expressions, you can assign any type to a variable and use it to create new types.

```js
phoneType = [Number, undefined]
nameType = {first: String, last: String, middle: [String, undefined]}
userType = {id: Number, name: nameType, phone: phoneType}
```
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

* `sig` as a decorator, [when JavaScript decorators reaches stage 4 and are implemented in CoffeeScript](https://github.com/jashkenas/coffeescript/issues/4917#issuecomment-387220758).

Licence
-------

MIT
