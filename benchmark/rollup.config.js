import commonjs from 'rollup-plugin-commonjs';
import nodeResolve from 'rollup-plugin-node-resolve';

const plugins = [
	nodeResolve({
		jsnext: true,
		main: true
	}),
	commonjs({
		sourceMap: false
	})
]

export default [
	{
		input: 'floweret.js',
		output: {
			file: 'bundles/floweret.bundle.js',
			format: 'umd',
			name: 'myBundle'
		},
		plugins
	},
	{
		input: 'flow-runtime.js',
		output: {
			file: 'bundles/flow-runtime.bundle.js',
			format: 'umd',
			name: 'myBundle'
		},
		plugins
	}
]
