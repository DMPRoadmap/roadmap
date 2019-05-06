process.env.NODE_ENV = process.env.NODE_ENV || 'stage'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
