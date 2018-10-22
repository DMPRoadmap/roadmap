// config/webpack/loaders/eslint.js
module.exports = {
  enforce: 'pre',
  test: /\.(js|jsx)$/i,
  exclude: /node_modules/,
  loader: 'eslint-loader',
}
