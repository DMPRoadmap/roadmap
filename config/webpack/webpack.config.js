const path = require('path');
const webpack = require('webpack');
const erbLoader = require('./loaders/erb');

const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production';

module.exports = {
  mode,
  devtool: mode === 'development' ? 'eval-cheap-module-source-map' : 'source-map',
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
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader'],
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        use: 'file-loader',
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
      React: 'react',
      ReactDOM: 'react-dom',
    }),
  ],
  resolve: {
    extensions: ['*', '.js', '.jsx'],
    alias: {
      react: path.resolve('./node_modules/react'),
    },
  },
};
