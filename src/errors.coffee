import shouldBe from './shouldBe'

class InvalidSignature extends Error
	name: 'InvalidSignature'

class InvalidType extends Error
	name: 'InvalidType'

export signatureError = (msg) -> throw new InvalidSignature msg

export invalidError = (msg) -> throw new InvalidType msg

export typeError = (prefix='', val, type, promised) ->
	throw new TypeError prefix + if arguments.length > 1 then  ' ' + shouldBe(val, type, promised) else ''
