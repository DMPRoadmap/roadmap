process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

environment.plugins.get('Manifest').opts.writeToFileEmit = process.env.NODE_ENV !== 'test'

environment.loaders.append('istanbul-instrumenter', {
  test: /\.ts$/,
  enforce: "post",
  loader: "istanbul-instrumenter-loader",
  query: {
    esModules: true
  },
  exclude: ["node_modules", /\.test\.ts$/]
});

module.exports = environment.toWebpackConfig()
