const { environment } = require('@rails/webpacker')
const eslint = require('./loaders/eslint')
const webpack = require('webpack')

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  jQuery: 'jquery',
  $: 'jquery',
  timeago: 'timeago.js',
  Popper: ['popper.js', 'default'],
}));

environment.loaders.prepend('ESLint', eslint)

module.exports = environment
