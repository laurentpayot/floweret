{InvalidTypeError} = require '.'

AnyType = -> if arguments.length then throw new InvalidTypeError "'AnyType' can not have a type argument." else []

module.exports = AnyType
