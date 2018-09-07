// Generated by CoffeeScript 2.3.1
(function() {
  /** @license MIT (c) 2018 Laurent Payot  */
  /* type helpers */
  var Etc, TypedMap, TypedObject, TypedSet, anyType, error, etc, isAnyType, isType, maybe, promised, sig, typeName, typeOf, typedMap, typedObject, typedSet;

  // trows customized error
  error = function(msg) {
    throw new Error((function() {
      switch (msg[0]) {
        case '!':
          return `Invalid type syntax: ${msg.slice(1)}`;
        case '@':
          return `Invalid signature: ${msg.slice(1)}`;
        default:
          return `Type error: ${msg}`;
      }
    })());
  };

  /* typed classes */
  TypedObject = class TypedObject {
    constructor(type1) {
      this.type = type1;
      if (arguments.length !== 1) {
        error("!typedObject must have exactly one type argument.");
      }
      if (isAnyType(this.type)) { // return needed
        return Object;
      }
    }

  };

  TypedSet = class TypedSet {
    constructor(type1) {
      this.type = type1;
      if (arguments.length !== 1) {
        error("!typedSet must have exactly one type argument.");
      }
      if (isAnyType(this.type)) { // return needed
        return Set;
      }
    }

  };

  TypedMap = (function() {
    class TypedMap {
      constructor(t1, t2) {
        switch (arguments.length) {
          case 0:
            error("!typedMap must have at least one type argument.");
            break;
          case 1:
            if (isAnyType(t1)) {
              return Map;
            } else {
              this.valuesType = t1; // return needed
            }
            break;
          case 2:
            if (isAnyType(t1) && isAnyType(t2)) {
              return Map;
            } else {
              [this.keysType, this.valuesType] = [
                t1,
                t2 // return needed
              ];
            }
            break;
          default:
            error("!typedMap can not have more than two type arguments.");
        }
      }

    };

    TypedMap.prototype.keysType = [];

    TypedMap.prototype.valuesType = [];

    return TypedMap;

  }).call(this);

  Etc = class Etc { // typed rest arguments list
    constructor(type1 = []) {
      this.type = type1;
      if (arguments.length > 1) {
        error("!'etc' can not have more than one type argument.");
      }
    }

  };

  // not exported
  isAnyType = function(o) {
    return o === anyType || Array.isArray(o) && o.length === 0;
  };

  anyType = function() {
    if (arguments.length) {
      return error("!'anyType' can not have a type argument.");
    } else {
      return [];
    }
  };

  maybe = function(...types) {
    if (!arguments.length) {
      error("!'maybe' must have at least one type argument.");
    }
    if (types.some(function(t) {
      return isAnyType(t);
    })) {
      return [];
    } else {
      return [void 0, null].concat(types);
    }
  };

  promised = function(type) {
    if (arguments.length !== 1) {
      error("!'promised' must have exactly one type argument.");
    }
    if (isAnyType(type)) {
      return Promise;
    } else {
      return Promise.resolve(type);
    }
  };

  typedObject = function(...args) {
    return new TypedObject(...args);
  };

  typedSet = function(...args) {
    return new TypedSet(...args);
  };

  typedMap = function(...args) {
    return new TypedMap(...args);
  };

  etc = function(...args) {
    return new Etc(...args);
  };

  // typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for null, Promise etc.
  // NB: returning string instead of class because of special array case http://web.mit.edu/jwalden/www/isArray.html
  typeOf = function(val) {
    if (val === void 0 || val === null) {
      return '' + val;
    } else {
      return val.constructor.name;
    }
  };

  // check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
  isType = function(val, type) {
    var k, keys, keysType, prefix, ref, ref1, t, v, values, valuesType;
    switch (typeOf(type)) {
      case 'undefined':
      case 'null':
      case 'String':
      case 'Number':
      case 'Boolean':
        return val === type; // literal type or undefined or null
      case 'Function':
        switch (type) {
          // type helpers used directly as functions
          case anyType:
            return true;
          case promised:
          case maybe:
          case typedObject:
          case typedSet:
          case typedMap:
            return error(`!'${type.name}' can not be used directly as a function.`);
          case etc:
            return error("!'etc' can not be used in types.!!!");
          default:
            // constructors of native types (Number, String, Object, Array, Promise, Set, Map…) and custom classes
            return (val != null ? val.constructor : void 0) === type;
        }
        break;
      case 'Array':
        switch (type.length) {
          case 0:
            return true; // any type: `[]`
          case 1: // typed array type, e.g.: `Array(String)`
            if (!Array.isArray(val)) {
              return false;
            }
            if (isAnyType(type[0])) {
              return true;
            }
            return val.every(function(e) {
              return isType(e, type[0]);
            });
          default:
            return type.some(function(t) {
              return isType(val, t); // union of types, e.g.: `[Object, null]`
            });
        }
        break;
      case 'Object': // Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
        if ((val != null ? val.constructor : void 0) !== Object) {
          return false;
        }
        if (!Object.keys(type).length) {
          return !Object.keys(val).length;
        }
        for (k in type) {
          v = type[k];
          if (!isType(val[k], v)) {
            return false;
          }
        }
        return true;
      case 'TypedObject':
        if ((val != null ? val.constructor : void 0) !== Object) {
          return false;
        }
        t = type.type;
        if (isAnyType(t)) {
          return true;
        }
        return Object.values(val).every(function(v) {
          return isType(v, t);
        });
      case 'TypedSet':
        if ((val != null ? val.constructor : void 0) !== Set) {
          return false;
        }
        t = type.type;
        if (isAnyType(t)) {
          return true;
        }
        if ((ref = typeOf(t)) === 'undefined' || ref === 'null' || ref === 'String' || ref === 'Number' || ref === 'Boolean') {
          error(`!Typed Set type can not be a literal of type '${t}'.`);
        }
        return [...val].every(function(e) {
          return isType(e, t);
        });
      case 'TypedMap':
        if ((val != null ? val.constructor : void 0) !== Map) {
          return false;
        }
        ({keysType, valuesType} = type);
        switch (false) {
          case !(isAnyType(keysType) && isAnyType(valuesType)):
            return true;
          case !isAnyType(keysType):
            return Array.from(val.values()).every(function(e) {
              return isType(e, valuesType);
            });
          case !isAnyType(valuesType):
            return Array.from(val.keys()).every(function(e) {
              return isType(e, keysType);
            });
          default:
            keys = Array.from(val.keys());
            values = Array.from(val.values());
            return keys.every(function(e) {
              return isType(e, keysType);
            }) && values.every(function(e) {
              return isType(e, valuesType);
            });
        }
        break;
      case 'Etc':
        return error("!'etc' can not be used in types.");
      default:
        prefix = (ref1 = typeOf(type)) === 'Set' || ref1 === 'Map' ? 'the provided Typed' : '';
        return error(`!Type can not be an instance of ${typeOf(type)}. Use ${prefix}${typeOf(type)} as type instead.`);
    }
  };

  // not exported: get type name for signature error messages (supposing type is always correct)
  typeName = function(type) {
    var t;
    switch (typeOf(type)) {
      case 'Array':
        if (type.length === 1) {
          return `array of ${typeName(type[0])}`;
        } else {
          return ((function() {
            var l, len, results;
            results = [];
            for (l = 0, len = type.length; l < len; l++) {
              t = type[l];
              results.push(typeName(t));
            }
            return results;
          })()).join(" or ");
        }
        break;
      case 'Function':
        return type.name;
      case 'Object':
        return "custom type";
      default:
        return typeOf(type);
    }
  };

  // wraps a function to check its arguments types and result type
  sig = function(argTypes, resType, f) {
    if (!Array.isArray(argTypes)) {
      error("@Array of arguments types is missing.");
    }
    if ((resType != null ? resType.constructor : void 0) === Function && !resType.name) {
      error("@Result type is missing.");
    }
    if ((f != null ? f.constructor : void 0) !== Function) {
      error("@Function to wrap is missing.");
    }
    return function(...args) { // returns an unfortunately anonymous function
      var arg, i, j, l, len, len1, m, ref, rest, result, t, type;
      rest = false;
      for (i = l = 0, len = argTypes.length; l < len; i = ++l) {
        type = argTypes[i];
        if (type === etc || (type != null ? type.constructor : void 0) === Etc) { // rest type
          if (i + 1 < argTypes.length) {
            error("@Rest type must be the last of the arguments types.");
          }
          rest = true;
          t = type === etc ? [] : type.type;
          if (!isAnyType(t)) { // no checks if rest type is any type
            ref = args.slice(i);
            for (j = m = 0, len1 = ref.length; m < len1; j = ++m) {
              arg = ref[j];
              if (!isType(arg, t)) {
                error(`Argument number ${i + j + 1} (${arg}) should be of type ${typeName(t)} instead of ${typeOf(arg)}.`);
              }
            }
          }
        } else {
          if (!isAnyType(type)) { // not checking type if type is any type
            if (args[i] === void 0) {
              if (!isType(void 0, type)) {
                error(`Missing required argument number ${i + 1}.`);
              }
            } else {
              if (!isType(args[i], type)) {
                error(`Argument number ${i + 1} (${args[i]}) should be of type ${typeName(type)} instead of ${typeOf(args[i])}.`);
              }
            }
          }
        }
      }
      if (args.length > argTypes.length && !rest) {
        error("Too many arguments provided.");
      }
      if ((resType != null ? resType.constructor : void 0) === Promise) {
        // NB: not using `await` because CS would transpile the returned function as an async one
        return resType.then(function(promiseType) {
          var promise;
          promise = f(...args);
          if ((promise != null ? promise.constructor : void 0) !== Promise) {
            error("Function should return a promise.");
          }
          return promise.then(function(result) {
            if (!isType(result, promiseType)) {
              error(`Promise result (${result}) should be of type ${typeName(promiseType)} instead of ${typeOf(result)}.`);
            }
            return result;
          });
        });
      } else {
        result = f(...args);
        if (!isType(result, resType)) {
          error(`Result (${result}) should be of type ${typeName(resType)} instead of ${typeOf(result)}.`);
        }
        return result;
      }
    };
  };

  module.exports = {typeOf, isType, sig, maybe, anyType, promised, etc, typedObject, typedSet, typedMap};

}).call(this);
