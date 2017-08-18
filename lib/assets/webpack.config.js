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
    vendor: ['jquery', 'tinymce/tinymce', 'tinymce/themes/modern/theme'],
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
        test: /\.woff2?$|\.ttf$|\.eot$|\.svg$/,
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
    new webpack.optimize.CommonsChunkPlugin({
      name: 'vendor',
      minChunks: Infinity,
    }),
    new webpack.ProvidePlugin({ // Load jquery module automatically instead of import everywhere
      $: 'jquery',
      jQuery: 'jquery',
    }),
    new CopyWebPackPlugin([ // Copies every file under images or videos
      { from: './images/**/*', to: `${destPath}/` },
      { from: './videos/**/*', to: `${destPath}/` },
      /* START DEPENDENCIES NEEDED FOR ES5 scripts */
      { from: './node_modules/jquery/dist/jquery.min.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/jquery-ujs/src/rails.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/jquery-ui-dist/jquery-ui.min.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/jquery-accessible-autocomplete-list-aria/jquery-accessible-autocomplete-list-aria.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/placeholder/dist/placeholder.min.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/tablesorter/dist/js/jquery.tablesorter.min.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/tablesorter/dist/js/jquery.tablesorter.widgets.min.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/timeago/jquery.timeago.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/tinymce/tinymce.min.js', to: `${destPath}/javascripts/` },
      { from: './node_modules/bootstrap-sass/assets/javascripts/bootstrap.min.js', to: `${destPath}/javascripts/` },
      { from: './javascripts/utils/**/*', to: `${destPath}/` },
      { from: './javascripts/dmproadmap/**/*', to: `${destPath}/` },
      { from: './javascripts/views/**/*', to: `${destPath}/` },
      { from: './javascripts/admin.js', to: `${destPath}/javascripts/` },
      /* END DEPENDENCIES NEEDED FOR ES5 scripts */
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
