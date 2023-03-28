// Local test environment (also used for GitHub actions)

process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const environment = require('./environment');

module.exports = environment.toWebpackConfig();
