process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const environment = require('./environment');

/* We only want the ESLint in dev mode */
const eslint = require('./loaders/eslint');
environment.loaders.prepend('ESLint', eslint);

module.exports = environment.toWebpackConfig();
