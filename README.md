runtime-signature
=================
Type-checking for functions at runtime with simple JavaScript types signatures.

Install
-------
**NB: Not on npm yet, stay tuned!**
```bash
$ npm install runtime-signature
# or
$ yarn add runtime-signature
```

Usage
-----
To add a signature to a function, we wrap the function with the `sig` function, like so:
```
sig([<arguments types>], <result type>, <function>)
```
### CoffeeScript :heart:
You can ommit the parentheses, resulting in a very clean syntax:

```coffeescript
import { sig } from 'runtime-signature'

add = sig [Number, [Number, undefined]], Number,
    (n1, n2=0) -> n1 + n2

add(5)      # 5
add(5, 1)   # 6
add('5', 1) # Error: Argument number 1 (5) should be of type Number instead of String.
```

### JavaScript
```js
import { sig } from 'runtime-signature';

const add = sig([Number, [Number, undefined]], Number,
  function(n1, n2 = 0) {
    return n1 + n2;
  });

add(5);      // 5
add(5, 1);   // 6
add('5', 1); // Error: Argument number 1 (5) should be of type Number instead of String.

```

Type syntax
-----------
### Native types
```
<native type>
```
All native JavaScript types are allowed as type:
`Number`, `String`, `Array`, `Object`, `undefined`, `null`, `Promise`, `Map`, `set`, etc.

### Union of types 
```
[<type 1>, <type 2>, … , <type n>]
```
You can create a type that is the union of several types. Simply put them in a list.
For instance the type `[Number, String, undefined]` will accept a number value or a string value or an undefined value.

### Typed arrays 
```
Array(<type>)
```
You can use the `Array` type for arrays with elements of any type, but most of the time it is better to specify the type of the elements.

Simply use `Array(Number)` for an array of number.

:warning: If you want an array with elements of a type that is the union of severay types, do not forget the brackets (`[` and `]`). Otherwise you will get the union of types instead of the array of union of types. 

* Use `Array([Number, String])` to accept an array of elements that can be numbers or strings, such as `[1, "2", 3]`.
* Use `[Array(Number), Array(String)]` to accept an array of numbers (such as `[1, 2, 3]`) or an array of strings (such as `["1", "2", "3"]`).

### Object types
```
{<key 1>: <type 1>, <key 2>: <type 2>, … , <key n>: <type n>}
```

`userType = {id: Number, name: {first: String, last: String, middle: [String, undefined]}}`

### Promise type
```
Promise.resolve(<type>)
```
A handy shortcut is graciously provided:
```
promised(<type>)
```
You can use the `Promise` type for promises that resolve with a value of any type, but most of the time it is better to specify the type of the resolved value.

For instance use `promised([Object, null])` for a promise that will resolve with an object or the null value.

### Any type wildcard
```
[]
```

### Type composition
As the type system uses JavaScript expressions, you can assign your type to a variable and use it to create new types.
```js
phoneType = [Number, undefined]
```

Type tools 
----------
`isType(value, type)` 
`typeOf(value)`

Licence
-------
MIT
