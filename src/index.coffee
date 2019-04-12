export {default as fn} from './fn'
export {default as check} from './check'
export {default as isValid} from './isValid'
export {default as typeOf} from './typeOf'

# ! Rollup unable to tree-shake classes https://github.com/rollup/rollup/issues/1691
# export * from './types'

# exporting types already used by fn
export {default as etc} from './types/etc'
export {default as Any} from './types/Any'
# exporting other frequently used types
export {default as maybe} from './types/maybe'
export {default as alias} from './types/alias'
