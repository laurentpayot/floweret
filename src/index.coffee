export {default as fn} from './fn'
export {default as isValid} from './isValid'
export {default as typeOf} from './typeOf'

#! Rollup unable to tree-shake classes https://github.com/rollup/rollup/issues/1691
# export * from './types'

# NB: exporting some types used anyway
export {default as etc} from './types/etc'
export {default as Any} from './types/Any'
