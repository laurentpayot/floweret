export {default as fn} from './fn'
export {default as typed} from './typed'
export {default as isValid} from './isValid'
export {default as typeOf} from './typeOf'

# ! Rollup unable to tree-shake classes https://github.com/rollup/rollup/issues/1691
# export * from './types'

# exporting types already used by fn
export {default as etc} from './types/etc'
export {default as Any} from './types/Any'

# exporting maybe() as it is often used
export {default as maybe} from './types/maybe'
