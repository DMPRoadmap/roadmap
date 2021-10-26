// Karma configuration
// Generated on Wed Nov 07 2018 08:26:22 GMT-0800 (Pacific Standard Time)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '../..',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: [
      'fixture',
      'jquery-3.3.1',
      'jasmine'
    ],

    plugins: [
      'karma-webpack',
      'karma-jquery',
      'karma-jasmine',
      'karma-fixture',
      'karma-html2js-preprocessor',
      'karma-json-fixtures-preprocessor',
      'karma-babel-preprocessor',
      'karma-chrome-launcher',
    ],

    // list of files / patterns to load in the browser
    files: [
      // 'node_modules/babel-polyfill/dist/polyfill.js',
      'node_modules/bootstrap/dist/js/bootstrap.min.js',
      'spec/javascripts/**/*Spec.js',
      'spec/javascripts/fixtures/*',
    ],

    // list of files / patterns to exclude
    exclude: [
    ],

    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      'spec/javascripts/**/*.js': ['webpack'],
      'spec/javascripts/**/*.js.erb': ['webpack'],
      'spec/javascripts/fixtures/*.html': ['html2js'],
      'spec/javascripts/fixtures/*.json': ['json_fixtures'],
    },

    webpack: require('../../config/webpack/test.js'),

    // Preprocessor configuration
    jsonFixturesPreprocessor: {
      variableName: '__json__',
    },

    webpackMiddleware: {
      // webpack-dev-middleware configuration
      stats: 'errors-only',
    },

    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],

    // web server port
    port: 9876,

    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,

    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: [
      'ChromeHeadlessCustom'
    ],
    // defining a custom browser to let this run in docker
    customLaunchers: {
      ChromeHeadlessCustom: {
        base: 'ChromeHeadless',
        flags: ['--no-sandbox']
      }
    },

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: true,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity,
  })
}
