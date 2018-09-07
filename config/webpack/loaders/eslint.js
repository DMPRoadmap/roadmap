// config/webpack/loaders/eslint.js
const { env } = require('../environment.js')

module.exports = {
  enforce: 'pre',
  test: /\.(js|jsx)$/i,
  exclude: /node_modules/,
  loader: 'eslint-loader',
  options: {
    failOnError: env.NODE_ENV !== 'production'
  }
}