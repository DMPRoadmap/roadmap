const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

const eslint = require('./loaders/eslint')

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  jQuery: 'jquery',
  $: 'jquery',
  timeago: 'timeago.js',
  Popper: ['popper.js', 'default'],
}));

environment.loaders.prepend('ESLint', eslint)

module.exports = environment