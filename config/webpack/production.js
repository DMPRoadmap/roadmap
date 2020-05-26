process.env.NODE_ENV = process.env.NODE_ENV || 'production';

const environment = require('./environment');
environment.plugins.get("UglifyJs").options.u glifyOptions.ecma = 5;

module.exports = environment.toWebpackConfig();
