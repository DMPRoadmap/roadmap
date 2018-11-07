// config/webpack/loaders/eslint.js
module.exports = {
  enforce: 'pre',
  test: /\.(js|jsx)$/i,
  exclude: /node_modules/,
  loader: 'eslint-loader',
  options: {
    useEslintrc: false,
    baseConfig: {
      "extends": "airbnb-base",
      "env": {
        "jasmine": true,
        "jquery": true
      },
      "globals": {
        "timeago": true,
        "fixture": true,
        "spyOnEvent": true
      },
    },
  },
}
