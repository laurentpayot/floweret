export {default as fn} from './fn'
export {default as obj} from './obj'
export {default as isValid} from './isValid'
export {default as typeOf} from './typeOf'

# ! Rollup unable to tree-shake classes https://github.com/rollup/rollup/issues/1691
# export * from './types'

# exporting some types used anyway
export {default as etc} from './types/etc'
export {default as Any} from './types/Any'

# exporting maybe() as it is generally always used
export {default as maybe} from './types/maybe'
