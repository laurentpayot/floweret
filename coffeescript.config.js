// https://github.com/jashkenas/coffeescript/issues/4769
require('module').prototype.options = {
	transpile: require('./babel.config')
};
require('coffeescript/register');
