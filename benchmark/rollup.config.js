import nodeResolve from 'rollup-plugin-node-resolve'
import commonjs from 'rollup-plugin-commonjs'
import { terser } from "rollup-plugin-terser"
import gzipPlugin from 'rollup-plugin-gzip'

// const format = 'cjs'
// const format = 'iife'
const format = 'umd'

const plugins = [
	nodeResolve({
		jsnext: true,
		main: true
	}),
	commonjs({
		sourceMap: false,
		namedExports: {
			// left-hand side can be an absolute path, a path
			// relative to the current directory, or the name
			// of a module in node_modules
			'runtypes/lib/index.js': ['Record', 'String', 'Contract', 'Array', 'Number']
		}
	}),
	terser({
		sourcemap: false
	}),
	gzipPlugin()
]

console.log("Bundling format:", format.toUpperCase())

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
	},
	{
		input: 'objectmodel.js',
		output: {
			file: 'bundles/objectmodel.min.js',
			name: 'myBundle',
			format
		},
		plugins
	}
]
