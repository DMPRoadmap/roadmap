const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const fs = require('fs');
const CopyWebPackPlugin = require('copy-webpack-plugin');

const rootPath = `${__dirname}/../..`;
const destPath = `${rootPath}/public`;
const production = process.argv.indexOf('-p') !== -1;
const jsOutputFile = production ? 'javascripts/[name]-[hash].js' : 'javascripts/[name].js';
const cssOutputFile = production ? 'stylesheets/[name]-[hash].css' : 'stylesheets/[name].css';
const fontOutputFile = 'fonts/[name].[ext]';
const extractSass = new ExtractTextPlugin({ filename: cssOutputFile });

module.exports = {
  context: __dirname,

  entry: {
    vendor: ['jquery', 'timeago.js', 'jquery-accessible-autocomplete-list-aria/jquery-accessible-autocomplete-list-aria', 'jquery-ujs'],
    application: ['./javascripts/application.js', './stylesheets/application.scss'],
  },

  output: {
    path: destPath,
    filename: jsOutputFile,
  },

  module: {
    rules: [
      {
        enforce: 'pre',
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'eslint-loader',
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015'],
        },
      },
      {
        test: /\.scss$/,
        use: extractSass.extract({
          use: ['css-loader', 'sass-loader'],
        }),
      },
      {
        test: /\.(jpg|png)$/,
        loader: 'url-loader',
        options: {
          limit: 10000,
        },
      },
      {
        test: /(?:fonts\/bootstrap\/.*)|(?:font-awesome\/fonts\/.*)|(?:customfonts\/fonts\/.*)(?:\.woff2?$|\.ttf$|\.eot$|\.svg$|\.woff$)/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: fontOutputFile,
              // outputPath: 'fonts/',
              publicPath: '../',
            },
          },
        ],
      },
    ],
  },

  plugins: [
    extractSass,
    new webpack.ProvidePlugin({ // Load jquery module automatically instead of import everywhere
      jQuery: 'jquery',
      $: 'jquery',
      timeago: 'timeago.js',
    }),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'vendor',
      minChunks: Infinity,
    }),
    new CopyWebPackPlugin([ // Copies every file under images or videos
      { from: './images/**/*', to: `${destPath}/` },
      { from: './videos/**/*', to: `${destPath}/` },
    ]),
    function deleteAssets() { // Deletes ONLY files within the following paths.
      const relativePaths = ['/javascripts', '/stylesheets', '/fonts'];
      this.plugin('compile', () => {
        if (production) {
          relativePaths.map(relativePath => destPath + relativePath)
            .forEach((absolutePath) => {
              fs.readdir(absolutePath, (err, files) => {
                if (files) {
                  files.forEach((file) => {
                    const path = `${absolutePath}/${file}`;
                    if (file.indexOf('.keep') === -1
                      && fs.statSync(path).isFile()) {
                      fs.unlinkSync(path);
                    }
                  });
                }
              });
            });
        }
      });
      this.plugin('done', (stats) => { // Changes value for ASSET_FINGERPRINT hash
        const output = `ASSET_FINGERPRINT = "${stats.hash}"`;
        fs.writeFileSync(`${rootPath}/config/initializers/fingerprint.rb`, output, 'utf-8');
      });
    },
  ],
  watch: !production,
};
