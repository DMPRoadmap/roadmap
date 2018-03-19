// Karma configuration
module.exports = function webpackKarmaConf(config) {
  config.set({
    // ... normal karma configuration
    files: [
      // all files ending in "_test"
      { pattern: './javascripts/**/*Spec.js', watched: false },
      // each file acts as entry point for the webpack configuration
    ],

    preprocessors: {
      './javascripts/**/*Spec.js': ['webpack'],
    },

    webpack: {
      // karma watches the test entry points
      // (you don't need to specify the entry option)
      // webpack watches dependencies

      // webpack configuration
    },

    webpackMiddleware: {
      // webpack-dev-middleware configuration
      // i. e.
      stats: 'errors-only',
    },
  });
};
