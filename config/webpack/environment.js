const { environment } = require('@rails/webpacker')

//TEMP fix for webpacker erb bug
environment.config.merge({
  module: {
    rules: [
      environment.loaders.get('erb')
    ]
  }
})
environment.loaders.delete('erb')

module.exports = environment
