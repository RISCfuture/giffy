const _ = require ('lodash')

const environment = require('./environment')

module.exports = _.merge(environment.toWebpackConfig(), {
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  }
})
