// Karma configuration
const webpackConfig = require('./webpack.karma.config.js');

module.exports = function karmaConfig(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['fixture', 'jquery-3.2.1', 'jasmine'],

    // list of files / patterns to load in the browser
    files: [
      './node_modules/phantomjs-polyfill/bind-polyfill.js',
      './node_modules/jasmine-jquery/lib/jasmine-jquery.js',
      'app/assets/javascripts/**/*Spec.js',
      'app/assets/javascripts/spec/fixtures/**/*',
    ],


    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      'app/assets/javascripts/**/*Spec.js': ['webpack'],
      'app/assets/javascripts/**/*.html': ['html2js'],
      'app/assets/javascripts/**/*.json': ['json_fixtures'],
    },

    webpack: webpackConfig,
    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR ||
    // config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    // browsers: ['Chrome'],
    browsers: ['Chrome', 'ChromeHeadless', 'ChromeHeadlessNoSandbox'],


    // From the Travis Docs: https://docs.travis-ci.com/user/chrome#karma-chrome-launcher
    customLaunchers: {
      ChromeHeadlessNoSandbox: {
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

    jsonFixturesPreprocessor: {
      variableName: '__json__',
    },
  });
};

