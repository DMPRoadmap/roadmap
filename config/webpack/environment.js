const { environment } = require('@rails/webpacker');
const erb =  require('./loaders/erb');
const webpack = require('webpack');

const eslint = require('./loaders/eslint');
const babelLoader = require('./loaders/babel-loader');

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  jQuery: 'jquery',
  $: 'jquery',
  timeago: 'timeago.js',
  Popper: ['popper.js', 'default'],
}));

environment.loaders.prepend('ESLint', eslint);
environment.loaders.append('Babel-Loader', babelLoader);

environment.loaders.append('erb', erb);

environment.config.set('resolve.alias', {
  'jquery-ui': 'jquery-ui/ui/widgets/',
  'bootstrap-sass': 'bootstrap-sass/assets/javascripts/bootstrap/',
});

module.exports = environment;
