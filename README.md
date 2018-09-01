runtime-signature
=================
Type-checking for functions at runtime with simple JavaScript types signatures.

Features
--------
* Native types `Number`
* Typed arrays `Array(Number)`
* Union of types `[Number, String]`
* Custom types `myType = {id: Number, name: {first: String, last: String, middle: [String, undefined]}}`
* Type composition `Array([Number, String])`
* Type of promise `promised([Object, null])`
* Any type wildcard `[]`
* Type tools `isType(val,type)` `typeOf(val)`

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
General usage:
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

Licence
-------
MIT
