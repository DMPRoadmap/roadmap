// config/webpack/loaders/eslint.js
module.exports = {
  enforce: 'pre',
  test: /\.(js|jsx)$/i,
  exclude: /node_modules|app\/javascript\/vendor/,
  loader: 'eslint-loader',
};
