const path = require('path');
const webpack = require('webpack');
const erbLoader = require('./loaders/erb');

const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production';

module.exports = {
  mode,
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: [{
          loader: 'babel-loader',
          options: {
            presets: [
              ['@babel/preset-env', {
                targets: 'defaults',
              }],
              '@babel/preset-react',
            ],
          },
        }],
      },
      erbLoader,
    ],
  },
  entry: {
    application: './app/javascript/application.js',
  },
  optimization: {
    moduleIds: 'deterministic',
  },
  output: {
    filename: '[name].js',
    sourceMapFilename: '[file].map',
    path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
      'global.jQuery': 'jquery',
    }),
  ],
  resolve: {
    extensions: ['*', '.js', '.jsx'],
  },
};
