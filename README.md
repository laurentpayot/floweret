runtime-signature
=================
Runtime type-checking with simple JavaScript types signatures.

Features
--------
* Native types
* Custom types (objects)
* Union of types
* Any type
* Promised type

Install
-------

```bash
$ yarn add runtime-signature
# or
$ npm install runtime-signature
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

add(5); // 5
add(5, 1); // 6
add('5', 1); // Error: Argument number 1 (5) should be of type Number instead of String.

```

Licence
-------
MIT
