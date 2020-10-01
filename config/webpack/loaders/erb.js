module.exports = {
  test: /\.erb$/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: [{
    loader: 'rails-erb-loader',
    options: {
      runner: '/dmp/local/bin/ruby ' + 'bin/rails runner'
    }
  }]
};
