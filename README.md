# :blossom: Floweret

[![Build Status](https://badgen.net/travis/laurentpayot/floweret)](https://travis-ci.org/laurentpayot/floweret)
[![Coverage Status](https://badgen.net/coveralls/c/github/laurentpayot/floweret)](https://coveralls.io/github/laurentpayot/floweret?branch=master)
[![npm dependencies](https://badgen.net/david/dep/laurentpayot/floweret)](https://david-dm.org/laurentpayot/floweret)
[![npm bundle size](https://badgen.net/bundlephobia/minzip/floweret)](https://bundlephobia.com/result?p=floweret)
[![npm version](https://badgen.net/npm/v/floweret)](https://www.npmjs.com/package/floweret)

![Archived repository](./archived.svg)

## Why

*Static* type checking can be achieved in CoffeeScript using [Flow’s Comment Types syntax](https://flow.org/en/docs/types/comments/):

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

but…

* Flow must be running in the background.
* Comments add "noise" to the source code.
* Difficult (impossible?) build tools integration (webpack, rollup).
* Cannot check types in the browser for external APIs results, form inputs validation etc.

Floweret was written in CoffeeScript specialy for CoffeeScript to solve these problems.
The previous example can be rewritten using a decorator-like syntax:

```coffee
import { fn } from 'floweret'

Obj =
  num: Number

f = fn String, Obj, String,
  (str, obj) -> str + obj.num
```

Floweret *runtime* type annotations are:

* **Intuitive**: Native JavaScript types usage. Useful error messages.
* **Powerful**: Type composition, promises, rest parameters, logical operators and more…
* **Lightweight**: No dependencies. Concise syntax that does not bloat your code. Typically [around 3 kB](#benchmark) minified and gzipped. Less if you use tree shaking.
* **Fast**: Direct type comparison. No string to parse.
* **Customizable**: Create your own types for your own needs.

Because the golden rule of CoffeeScript is *“It’s just JavaScript.”*, you can easily use Floweret with plain JavaScript if you need runtime type checking. You simply miss the decorator-like syntaxic sugar allowed by CoffeeScript as [JavaScript decorators proposal](https://github.com/tc39/proposal-decorators) does not support standalone functions yet:

```js
// ES6 example
import { fn } from 'floweret'

const Obj = {
  num: Number
}

const f = fn(
  String, Obj, String,
  (str, obj) => str + obj.num
)
```

## Contents

* [Install](#install)
* [Function typing](#function-typing)
  * [Absence of type](#absence-of-type)
  * [Promised type](#promised-type)
  * [Rest arguments type](#rest-arguments-type)
  * [Unchecked type](#unchecked-type)
* [Variable typing](#variable-typing)
* [Type aliases](#type-aliases)
* [Tools](#tools)
  * [isValid](#isvalid)
  * [typeOf](#typeof)
* [Type reference](#type-reference)
  * [Basic types](#basic-types)
    * [Native types](#native-types)
    * [Literal type](#literal-type)
    * [Regular expression type](#regular-expression-type)
    * [Union of types](#union-of-types)
    * [Maybe type](#maybe-type)
    * [Typed array type](#typed-array-type)
    * [Sized array type](#sized-array-type)
    * [Object type](#object-type)
    * [Class type](#class-type)
    * [Any type](#any-type)
  * [Advanced types](#advanced-types)
    * [Tuple](#tuple)
    * [Typed Object](#typed-object)
    * [Typed Set](#typed-set)
    * [Typed Map](#typed-map)
    * [Integer](#integer)
    * [Sized string](#sized-string)
    * [Logical operators](#logical-operators)
      * [Or](#or)
      * [And](#and)
      * [Not](#not)
    * [Named type](#named-type)
    * [Constraint type](#constraint-type)
    * [Custom types](#custom-types)
  * [Type composition](#type-composition)
* [Benchmark](#benchmark)
* [License](#license)

## Install

```bash
$ npm install floweret
```

or

```bash
$ yarn add floweret
```

## Function typing

> fn <argument 1 type\>, <argument 2 type\>, …, <argument n type\>, <result type\>, <function\>

To add a signature to a function, wrap the function with the `fn` function.
`fn` arguments are first the list of arguments types, followed by the result type, and finally the function itself.

In the example below we will use [native](#native-types), [`maybe`](#maybe-type), [`union`](#union-of-types), and [`object`](#object-type) types as well as [type aliases](#type-aliases). All these types are detailed in the [Type reference](#type-reference) section of this document.

```coffee
import { fn, maybe, alias } from 'floweret'

Mode = alias 'TextMode', # alias is optional, but is good practice
  ['asIs', 'trimed'] # union of valid string litterals

Info = alias 'TextInfo',
  size: Number
  hasSpam: Boolean

#     arg. #1 type↰     ↱arg. #2 type ↱result type
recipeInfo = fn String, maybe(Mode), Info,
  (str, mode='asIs') ->
    size: (if mode is 'trimed' then str.trim() else str).length
    hasSpam: /spam/i.test(str)

# {size: 24, hasSpam: true}
sandwichInfo = recipeInfo(" egg spam spam bacon spam   ", 'trimed')

# the result is type-checked as TextInfo
sandwichInfo.size = "foo" # TypeError: Expected TextInfo: an object with key 'size' of type 'Number' instead of String "foo".

recipeInfo() # TypeError: Expected argument #1 to be String, got undefined.
recipeInfo(1) # TypeError: Expected argument #1 to be String, got Number 1.
recipeInfo("egg sausage", 'foo') # TypeError: Expected argument #2 to be undefined or TextMode, got String "foo".
```

As mentioned in the comments, the object returned by the function is *type-checked*. It means that a check is performed before every modification of the result object to ensure all type expectations are always met. The function parameters also are type-checked internally to the function, as long as they are objects (Object, Array, Set, Map, etc.).

More on this in the [variable typing section](#variable-typing) of this document.

### Absence of type

When the function takes no argument, only the result type is needed:

```coffee
returnHi = fn String,
  -> "Hi"

returnHi()  # Hi
returnHi(1) # TypeError: Too many arguments provided.
```

Use `undefined` as the result type when the function returns nothing (undefined):

```coffee
logInfo = fn String, undefined,
  (msg) -> console.log("Info:", msg)

logInfo("Boo.") # logs "Info: Boo.", returns undefined

logHi = fn undefined,
  -> console.log("Hi")

logHi() # logs "Hi", returns undefined
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

```coffee
getUserById = fn Number, Promise.resolve([Object, null]),
  (id) ->
    new Promise (resolve) ->
      # simulating slow database/network access
      setTimeout(->
        if id then resolve({id, name: "Bob"}) else resolve("anonymous")
      , 1000)

(-> await getUserById(1234))() # {id: 1234, name: "Bob"}
(-> await getUserById(0))() # TypeError: Expected promise result to be Object or null, got String "anonymous".
```

### Rest arguments type

> etc(<type\>)

or (untyped)

> etc

```coffee
import { fn, etc } from 'floweret'

average = fn etc(Number), [Number, NaN], # for Floweret NaN is NOT a Number (unlike JavaScript)
  (numbers...) -> numbers.reduce((acc, curr) -> acc + curr, 0) / numbers.length

average()           # NaN (0/0)
average(2, 6, 4)    # 4
average([2, 6, 4])  # TypeError: Expected argument #1 to be Number, got Array of 3 elements.
average(2, true, 4) # TypeError: Expected argument #2 to be Number, got Boolean true.
```

* **:warning:** Rest type can only be the last type of the signature arguments types, [as it should be in JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters#Description). CoffeeScript doesn't have this limitation, but this neat CoffeeScript feature is not implemented (yet) in floweret.

### Unchecked type

> import unchecked from 'floweret/types/unchecked'
>
> unchecked(<type\>)

In case you do not want the object returned by your function to be type-checked − because it means it is accessed via an [ES6 proxy](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy) (Object, Array) or is subclassed (Set, Map) − you can use the `unchecked` type:

```coffee
import { fn, Any } from 'floweret'
import unchecked from 'floweret/types/unchecked'

Numbers = Array(Number)

addToNumbers = fn Numbers, Any, unchecked(Numbers),
  (array, number) ->
    # NB: `array.push(number)` would throw a type error as `array` parameter is type-checked inside the function
    [array..., number]

# the result is still type-checked inside the function
addToNumbers([1, 2], true) # TypeError: Expected result to be an array with element 2 of type 'Number' instead of Boolean true.

a = addToNumbers([1, 2], 3) # [1, 2, 3]
# no error as `a` is not type-checked
a.push(true) # [1, 2, 3, true]
```

See the [variable typing section](#variable-typing) of this document for more details.

## Variable typing

> check <type\>, <value\>

When you need to ensure a variable type, you can make it type-checked just like a `fn` argument with the `checked` type:

```coffee
import { check } from 'floweret'

Store =
  darkMode: Boolean
  userId: Number
  displayName: String

store = check Store,
  darkMode: on
  userId: 12345678
  displayName: "Laurent"

# TypeError: Expected an object with key 'darkMode' of type 'Boolean' instead of Number 1.
store.darkMode = 1
```

`check` actualy does two things:

1) **Before the variable instantiation**: checks if the value is of the correct type and raises a type error if not.
2) **If the value is mutable**: adds a transparent type checking mechanism when the value is modified:
    * If the value is **an object or an array**: wraps it with an [ES6 proxy](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy).
    * If the value is **a set or a map**: makes the value an instance of a "type checking" subclass of Set or Map.

So if the value argument of `check` is immutable, the type will only be checked before the variable instantiation:

```coffee
import { check } from 'floweret'

# type is always checked before instantiation
name = check String, 1234 # TypeError: Expected String, got Number 1234.

name = check String, "Laurent"
name = 1234 # no error, strings are not mutable
```

* **:warning:** When using [union of types](#union-of-types), the variable will be instantiated with the first type matching the union. There will no more type checking for other types of the union:

```coffee
import { check } from 'floweret'

foo = check [{prop: String}, {prop: Number}],
  prop: "abc"

foo.prop = 1 # TypeError: Expected an object with key 'prop' of type 'String' instead of Number 1.
```

## Type aliases

> alias <name\>, <type\>

Using type aliases is good practice because an alias allows the name of the type to be "stored" within the type itself (if you need to export it) and gives more useful error messages.

Note the difference from the [example without alias](#variable-typing):

```coffee
import { check, alias } from 'floweret'

Store = alias 'MyAppStore',
  darkMode: Boolean
  userId: Number
  displayName: String

store = check Store,
  darkMode: on
  userId: 12345678
  displayName: "Laurent"

# TypeError: Expected MyAppStore: an object with key 'darkMode' of type 'Boolean' instead of Number 1.
store.darkMode = 1
```

## Tools

Some handy utilities exported by the package.

### isValid

> isValid <type\>, <value\>

`isValid` can tell if a value is of a given type. Useful for user input validation.

```coffee
import { isValid } from 'floweret'

Sauce = ['BBQ', 'Ketchup', 'Mayo']

isValid Sauce, 'Mayo' # true
isValid Sauce, 'Blanche' # false
```

### typeOf

> typeOf <value\>

The `typeOf` function is a replacement of the standard JavaScript `typeof` operator:

```coffee
import { typeOf } from 'floweret'

# standard JavaScript `typeof` operator
typeof [1, 2] # 'object'
typeof Promise.resolve(1) # 'object'
typeof NaN # 'number'

# more usefull results
typeOf [1, 2] # 'Array'
typeOf Promise.resolve(1) # 'Promise'
typeOf NaN # 'NaN'
```

## Type reference

### Basic types

#### Native types

> <native type\>

All native JavaScript type constructors are allowed as type:
`Number`, `String`, `Array`, `Object`, `Boolean`, `RegExp`, `undefined`, `null`, `Promise`, `Function`, `Set`, `Map`, `WeakMap`, `WeakSet`, etc.

```coffee
f = fn Number, String, Array,
  (a, b) -> [a, b]

f(1, 'a') # [1, 'a']
f(1, 5)   # TypeError: Expected argument #2 to be String, got Number 5.
```

#### Literal type

> <string or number or boolean or undefined or null or NaN\>

A literal can only be a string, a number, a boolean or be equal to `undefined` or `null` or `NaN`. Literals are useful when used inside an union list.

```coffee

Direction = ['left', 'right']

turn = fn Direction, String,
  (direction) -> "turning " + direction

turn('left')  # "turning left"
turn('light') # TypeError: Expected argument #1 to be literal String "left" or literal String "right", got String "light".
```

#### Regular Expression type

> <regular expression\>

When the type is a regular expression, if the value is a string it will be tested to see if it matches the regular expression.

```coffee
Email = /\S+@\S+\.\S+/ # simple email RegExp, do not use in production

showEmail = fn Email, String, String, undefined,
  (email, subject, content) -> console.table({ email, subject, content })

# nice email display
showEmail('laurent@example.com', "Hi", "Hello!")

# TypeError: Expected argument #1 to be string matching regular expression /\S+@\S+\.\S+/, got String "laurent.example.com".
showEmail('laurent.example.com', "Hi", "Hello!")
```

* **:warning:** Regular expressions are slow so if you need to check a lot of data consider using a [constraint type](#constraint-type) with String prototype methods instead.

#### Union of types

> [ <type 1\>, <type 2\>, …, <type n\> ]

You can create a type that is the union of several types. Simply put them between brackets.
For instance the type `[Number, String]` will accept a number or a string.

```coffee
f = fn Number, [Number, String], String,
  (a, b) -> '' + a + b

f(1, 2)    # '12'
f(1, '2')  # '12'
f(1, true) # TypeError: Expected argument #2 to be Number or String, got Boolean true.
```

#### Maybe type

> maybe( <type\> )

Usefull for optional parameters of a function. This is simply a shortcut to the union `[undefined, <type>]`.

* **:warning:** Unlike [Flow's maybe types](https://flow.org/en/docs/types/maybe/), a `null` value will generate an error, as it should.

```coffee
import { fn, maybe } from 'floweret'

f = fn Number, maybe(Number), Number,
  (a, b=0) -> a + b

f(5)       # 5
f(5, 1)    # 6
f(5, '1')  # TypeError: Expected argument #2 to be undefined or Number, got String "1".
f(5, null) # TypeError: Expected argument #2 to be undefined or Number, got null.
```

#### Typed array type

> Array(<type\>)

You can use the `Array` constructor type for arrays with elements of any type, but most of the time it is better to specify the type of the elements.

If you want to specify the type of the elements of an array, use this type as the `Array` constructor argument. For instance simply use `Array(String)` for an array of strings:

```coffee
dashJoin = fn Array(String), String,
  (strings) -> strings.join('-')

dashJoin(["a", "b", "c"]) # "a-b-c"
dashJoin(["a", "b", 3])   # TypeError: Expected argument #1 to be an array with element 2 of type 'String' instead of Number 3.
```

* **:warning:** If you want an array with elements of a type that is the union of severay types, do not forget the brackets (`[` and `]`).
  * Use `Array([Number, String])` to accept an array of elements that can be numbers or strings, such as `[1, "2", 3]`.
  * If you forget the brackets you will get the union of types instead of the array of union of types, because in JavaScript `Array(Number, String)` is the same as `[Number, String]`.

#### Sized array type

> Array(<length\>)

If you want to specify the length of an array, use this length as the `Array` constructor argument.

For instance use `Array(5)` for an array of five elements:

```coffee
pokerHand = fn Array(5), String,
  (cards) -> cards.join('-')

pokerHand([7, 9, "Q", "K", 1])     # 7-9-Q-K-1
pokerHand([7, 9, 10, "Q", "K", 1]) # TypeError: Expected argument #1 to be an array with a length of 5 instead of 6.
```

Sized array type is useful when used in conjunction with a typed array type, thanks to the [`and` operator](#and).
Note that you can use the empty array `[]` for an array of size 0 type, if you ever need it.

#### Object type

> {<key 1\>: <type 1\>, <key 2\>: <type 2\>, …, <key n\>: <type n\>}

You can specify the types of an object values, at any depth.

```coffee
User =
  id: Number
  name:
    first: String
    last: String
    middle: [String, undefined]

fullName = fn User, String,
  (user) -> Object.keys(user.name).join(' ')

Bob =
  id: 1234
  name:
    first: "Robert"
    last: "Smith"

# "Robert Smith"
fullName(Bob)

# TypeError: Expected argument #1 to be an object with key 'name.first' of type 'String' instead of Number 1.
fullName({id: 1234, name: {first: 1, last: "Smith"}})
```

* **:warning:** If values of an object argument match all the key types of the object type, **the argument will be accepted even if it has more keys than the object type** (except if type is the empty object `{}`):

```coffee
f = fn {a: Boolean, b: {x: Number, y: Number}}, Number,
  (obj) -> obj.b.x + obj.b.y

f({a: true, b: {x: 1, y: 2}}) # 3
f({a: true, b: {x: 1, y: 2}, foo: "bar"}) # 3 (no error)
f({a: true, b: {x: 1, z: 2}}) # TypeError: Expected argument #1 to be an object with key 'b.y' of type 'Number' instead of missing key 'y'.
f({a: true, b: {x: 1, y: undefined}}) # TypeError: Expected argument #1 to be an object with key 'b.y' of type 'Number' instead of undefined.
```

#### Class type

> <class\>

Simply use the class itself as the type:

```coffee
class Rectangle
  constructor: (@height, @width) ->

# Of course it would be better to have superficy() as a Rectangle method,
# but that is not the point…
superficy = fn Rectangle, Number,
  (rect) -> rect.height * rect.width

rect = new Rectangle(10, 5)

superficy(rect) # 50
superficy("foo") # TypeError: Expected argument #1 to be Rectangle, got String "foo".
superficy({height: 10, width: 5}) # TypeError: Expected argument #1 to be Rectangle, got Object.
```

#### Any type

> Any

Use the `Any` type when a parameter or a result can be of any type:

```coffee
import { fn, Any } from 'floweret'

log = fn Any, undefined,
  (x) -> console.log(x)

log("foo") # logs "foo"
log({a: 1, b: 2}) # logs Object {a: 1, b: 2}
```

### Advanced types

Advanced types are not accessible via the Floweret named exports object, they have to be imported from the `floweret/types` directory.

#### Tuple

> Tuple( <type 1\>, <type 2\>, …, <type n\> )

`Tuple` is a quite useful type that you can use for arrays containing a constant number of values, each one of a predetermined type.

```coffee
import { fn } from 'floweret'
import Tuple from 'floweret/types/Tuple'

# https://www.brasnthings.com/size-guide/bra-sizing
Cup = alias "BraCup",
  ['A', 'B', 'C', 'D', 'DD', 'E', 'F', 'G', 'H']
BraSize = Tuple(Number, Cup)

braSizeLabel = fn BraSize, String,
  (braSize) -> braSize.join('-')

braSizeLabel([95, 'C'])   # "90-C"
braSizeLabel([true, 'C']) # TypeError: Expected argument #1 tuple element 0 to be Number, got Boolean true.
braSizeLabel([200, 'Z']) # TypeError: Expected argument #1 tuple element 1 to be BraCup, got String "Z".
```

#### Typed Object

> TypedObject(<values type\>)

Typed object types are useful for object types with values of a given type.
Key type is always `String`, just like normal objects.

```coffee
import { fn } from 'floweret'
import TypedObject from 'floweret/types/TypedObject'

Results = TypedObject(Number)

maxGrade = fn Results, Number,
  (results) -> Math.max(Object.values(results)...)

maxGrade(
    Alice: 8.5
    Larry: 8
    Bob: 9.1
) # 9.1

maxGrade(
    Alice: 8.5
    Larry: "B"
    Bob: 9.1
) # TypeError: Expected argument #1 object property 'Larry' to be Number, got String "B".
```

#### Typed Set

> TypedSet(<elements type\>)

As expected, to ensure the type of the `Set` elements:

```coffee
import { fn } from 'floweret'
import TypedSet from 'floweret/types/TypedSet'

isSalty = fn TypedSet(String), Boolean,
  (ingredients) -> [ingredients...].includes('salt')

isSalty(new Set(["chocolate", "salt", "banana"])) # true
isSalty(new Set(["chocolate", "salt", 100])) # TypeError: Expected argument #1 set element to be String, got Number 100.
```

#### Typed Map

> TypedMap(<values type\>)

or

> TypedMap(<keys type\>, <values type\>)

* With a single argument, `TypedMap` works like [`TypedObject`](#typed-object), but for maps instead of objects. Only the value type is specified.
* With two arguments, `TypedMap` allows you to specify both key type (first argument) and value type(second argument).

#### Integer

> Integer

or

> Integer(<maximum value\>)

or

> Integer(<minimum value\>, <maximum value\>)

* Use `Integer` with two arguments to specify values range for an integer number.
* If only one argument is provided, it is considered as the maximum value, the minimum value being 0. Thus use `Integer(Number.MAX_SAFE_INTEGER)` for positive integers including 0.
* Used without argument, `Integer` simply specify an integer number, positive or negative.

```coffee
import { fn } from 'floweret'
import Integer from 'floweret/types/Integer'

Temperature = Integer(-70, 70)

maxTemperature = fn Array(Temperature), Temperature,
  (temperatures) -> Math.max(temperatures...)

maxTemperature([5, -2, 20, 17]) # 20

# TypeError: Expected argument #1 to be an array with element 3 of type 'Integer bigger than or equal to -70 and smaller than or equal to 70' instead of Number 170.
maxTemperature([5, -2, 20, 170])
```

#### Sized string

> SizedString(<maximum length\>)

or

> SizedString(<minimum length\>, <maximum length\>)

* Use `SizedString` with a single maximum length argument for strings that can be empty or with a maximum numbers of characters.
* With two arguments, `SizedString` allows you to specify strings of a minimum and a maximum length. Use `0` as second argument if you want to specify a minimum length but no maximum length.

```coffee
import { fn } from 'floweret'
import SizedString from 'floweret/types/SizedString'

# https://en.wikipedia.org/wiki/United_States_license_plate_designs_and_serial_formats
Plate = SizedString(5, 8)

isMagnumDriving = fn Plate, Boolean,
  (plate) -> plate is "ROBIN-1"

# TypeError: Expected argument #1 to be SizedString of at least 5 characters and of at most 8 characters, got String "Robin Masters".
isMagnumDriving("Robin Masters")
```

#### Logical operators

* **:warning:** **:coffee:** `or`, `and` and `not` are reserved CoffeeScript words. In the examples below we will import them as `Or`, `And` and `Not.`

##### Or

> or( <type 1\>, <type 2\>, …, <type n\> )

`or` is the same as the [union of types](#union-of-types) brackets notation, but more explicit.

```coffee
import { fn } from 'floweret'
import Or from 'floweret/types/or'

size = fn Or(String, Array), Number,
  (x) -> x.length

size("ab")       # 2
size(['a', 'b']) # 2
size({a: 'b'})   # TypeError: Expected argument #1 to be String or Array, got Object.
```

##### And

> and( <type 1\>, <type 2\>, …, <type n\> )

`and` is for intersection of types. It is useful with [constraint types](#constraint-type) or to specify typed arrays of a given length:

```coffee
import { fn } from 'floweret'
import And from 'floweret/types/and'

weeklyMax = fn And(Array(Number), Array(7)), Number,
  (days) -> Math.max(days...)

weeklyMax([1, 1, 2, 2, 5, 5, 1]) # 5
weeklyMax([1, 1, 2, 2, 5, 5])  # TypeError: Expected argument #1 to be 'array of 'Number'' and 'array of 7 elements', got Array of 6 elements.
```

##### Not

> not( <type\> )

`not` is the the complement type, i. e. for items not matching the type:

```coffee
import { fn } from 'floweret'
import Not from 'floweret/types/not'

getConstructor = fn Not([undefined, null]), Function,
  (x) -> x.constructor

getConstructor(1)    # function Number()
getConstructor(null) # TypeError: Expected argument #1 to be not 'undefined or null', got null.
```

#### Named type

> named(<type name\>)

Sometimes when you use external libraries you have to handle instances whithout having access to their classes definitions, but only their names. You can use the `named` type to check that the instance constructor name is correct.

Here is a Firebase example where we wrap the [createUser](https://firebase.google.com/docs/reference/admin/node/admin.auth.Auth#createUser)
function that returns a promise of a *Firebase-defined* `UserRecord` instance:

```coffee
import { fn, alias } from 'floweret'
import named from 'floweret/types/named'

import * as admin from 'firebase-admin'
admin.initializeApp(### your Firebase config ###)

export createUser = fn Object, Promise.resolve(named('UserRecord')),
  (data) -> admin.auth().createUser(data)
            .catch((err) -> console.error("User Creation:", err.message))
)
```

Some other times you cannot use the foreign class name because it has been mangled by a minifier and is subject to change. In such a case you can use the [Object type](#object-type) to do some *duck typing* with some (not necessarily all) properties of the foreign type instance.
The above example could end with:

```coffee
# using an alias is optional
User = alias "UserRecord",
  uid: String
  emailVerified: Boolean
  disabled: Boolean

export createUser = fn Object, Promise.resolve(User),
  (data) -> admin.auth().createUser(data)
            .catch((err) -> console.error("User Creation:", err.message))
)
```

### Constraint type

> constraint(<function\>)

You can quickly create new types using the `constraint` type, that takes a validation function as argument:

```coffee
import { fn } from 'floweret'
import constraint from 'floweret/types/constraint'

Int = constraint(Number.isInteger)

f = fn Int, String,
  n -> n + " eggs needed for that recipe"

f(2)   # "2 eggs needed for that recipe"
f(2.5) # TypeError: Expected argument #1 to be constrained by function 'isInteger', got Number 2.5.
```

`constraint` also work with anonymous validation functions:

```coffee
import { fn } from 'floweret'
import constraint from 'floweret/types/constraint'

Pos = constraint((x) -> x >= 0)

f = fn Pos, String,
  (n) -> "a distance of #{n} meters"

f(2.5) # "a distance of 2.5 meters"

# TypeError: Expected argument #1 to be constrained by 'function(x) {
#    return x >= 0;
#  }', got Number -2.5.
f(-2.5)
```

### Custom types

If you need more complex types you can create your own custom types, like the ones in the [`floweret/types` directory](https://github.com/laurentpayot/floweret/tree/master/src/types). Custom types have to be a subclass of `Type`.

*Documentation in progress…*

## Type composition

As types are simply JavaScript expressions, you can assign any type to a variable and use it to create new types:

```coffee
Phone = [Number, undefined]

Name =
  first: String
  last: String
  middle: [String, undefined]

User =
  id: Number
  name: Name
  phone: Phone
```

## Benchmark

Run the benchmark with:

```shell
npm run benchmark
```

The benchmark currently includes the folowing runtime type checking systems:

* **no type checking**: the reference results.
* [**Floweret**](https://github.com/laurentpayot/floweret): "Runtime type annotations for CoffeeScript (and JavaScript too!)" − CoffeeScript-oriented
* [**Runtypes**](https://github.com/pelotom/runtypes): "Runtime validation for static types" − TypeScript-oriented
* [**Object Model**](https://github.com/sylvainpolletvillard/ObjectModel): "Strong Dynamically Typed Object Modeling for JavaScript."
* [**Flow-runtime**](https://codemix.github.io/flow-runtime): "Flow-compatible runtime type system for JavaScript." − Flow-oriented

The [sub-benchmarks](https://github.com/laurentpayot/floweret/tree/master/benchmark) are run from minified [Rollup](https://rollupjs.org) bundles (UMD) and call two simple functions several thousand times.

Here are some results from my low spec Ubuntu laptop with node v12.13.0:

```txt
no-type-checking-benchmark.min.js.gz  257 bytes
floweret-benchmark.min.js.gz          3436 bytes
runtypes.min.js.gz                    3643 bytes
objectmodel.min.js.gz                 4092 bytes
flow-runtime-benchmark.min.js.gz      20296 bytes


*** No type checking ***
10000 greets: 16.885ms
10000 sums: 269.751ms

*** Floweret ***
10000 greets: 113.636ms
10000 sums: 844.946ms

*** Runtypes ***
10000 greets: 41.068ms
10000 sums: 213.717ms

*** Object Model ***
10000 greets: 532.950ms
10000 sums: 3632.958ms

*** Flow-runtime ***
10000 greets: 1169.674ms
10000 sums: 1508.513ms
```

Feel free to make your own benchmarks and share the results.

## License

[MIT](https://choosealicense.com/licenses/mit/)
