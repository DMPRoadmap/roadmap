const { environment } = require('@rails/webpacker');
const erb = require('./loaders/erb');
const webpack = require('webpack');

environment.loaders.prepend('erb', erb);

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
}));

environment.config.set('resolve.alias', {
  'jquery-ui': 'jquery-ui/ui/widgets/',
  'bootstrap-sass': 'bootstrap-sass/assets/javascripts/bootstrap/',
});

module.exports = environment;
