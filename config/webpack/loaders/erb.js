module.exports = {
  test: /\.erb$/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: [{
    loader: 'rails-erb-loader',
    options: {
      runner: (/^win/.test(process.platform) ? '/dmp/local/bin/ruby ' : '') + 'bin/rails runner'
    }
  }]
}

/* DMPTool Customization - had to be more specific with the location of ruby */
/* runner: (/^win/.test(process.platform) ? 'ruby ' : '') + 'bin/rails runner', */
