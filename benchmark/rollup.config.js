import commonjs from 'rollup-plugin-commonjs'
import nodeResolve from 'rollup-plugin-node-resolve'
import { terser } from "rollup-plugin-terser"
import gzipPlugin from 'rollup-plugin-gzip'

// const format = 'cjs'
// const format = 'iife'
const format = 'umd'

console.log("Bundling format:", format)

const plugins = [
	nodeResolve({
		jsnext: true,
		main: true
	}),
	commonjs({
		sourceMap: false
	}),
	terser({
		sourcemap: false,
		compress: {
			hoist_vars: true // needed for Floweret bundle
		},
		mangle: true
	}),
	gzipPlugin()
]

export default [
	{
		input: 'no-type-checking.js',
		output: {
			file: 'bundles/no-type-checking-benchmark.min.js',
			name: 'myBundle',
			format
		},
		plugins
	},
	{
		input: 'floweret.js',
		output: {
			file: 'bundles/floweret-benchmark.min.js',
			name: 'myBundle',
			format
		},
		plugins
	},
	{
		input: 'flow-runtime.js',
		output: {
			file: 'bundles/flow-runtime-benchmark.min.js',
			name: 'myBundle',
			format
		},
		plugins
	},
	{
		input: 'runtypes.js',
		output: {
			file: 'bundles/runtypes.min.js',
			name: 'myBundle',
			format
		},
		plugins
	}
]
