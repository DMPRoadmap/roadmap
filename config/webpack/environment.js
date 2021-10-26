const { environment } = require('@rails/webpacker');
const erb = require('./loaders/erb');
const webpack = require('webpack');
const eslint = require('./loaders/eslint');

environment.loaders.prepend('erb', erb);
environment.loaders.prepend('ESLint', eslint);

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  timeago: 'timeago.js',
}));

environment.config.set('resolve.alias', {
  'jquery-ui': 'jquery-ui/ui/widgets/',
  'bootstrap-sass': 'bootstrap-sass/assets/javascripts/bootstrap/',
});

environment.loaders.prepend('erb', erb)
module.exports = environment;
