process.env.NODE_ENV = process.env.NODE_ENV || 'uat'

const environment = require('./environment')
environment.plugins.get("UglifyJs").options.uglifyOptions.ecma = 5

module.exports = environment.toWebpackConfig()
