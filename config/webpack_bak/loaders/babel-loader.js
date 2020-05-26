// config/webpack/loaders/babel-loader.js
module.exports = {
  test: /\.(js|jsx)$/i,
  exclude: /node_modules\/(?!number-to-text)/,
  loader: 'babel-loader'
}
