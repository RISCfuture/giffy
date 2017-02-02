source 'https://rubygems.org'

# FRAMEWORK
gem 'rails', '5.0.1'
gem 'configoro'

# MODELS
gem 'pg'
gem 'find_or_create_on_scopes'
gem 'url_validation'

# VIEWS
gem 'sprockets-rails'
# HTML
gem 'slim-rails'
# CSS
gem 'sass-rails'
gem 'autoprefixer-rails'
# JS
gem 'coffee-rails'
gem 'uglifier'
gem 'therubyracer', platforms: :ruby
gem 'sprockets-es6', require: 'sprockets/es6'
gem 'turbolinks'
source 'https://rails-assets.org' do
  gem 'rails-assets-axios'
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-i18next'
  gem 'rails-assets-vue-i18next'
  gem 'rails-assets-i18next-xhr-backend'
end
# JSON
gem 'jbuilder'

# API
gem 'addressable'
gem 'faraday'
gem 'json'
gem 'nokogiri'

# LATEX
gem 'aws-sdk'

group :development do
  gem 'puma'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'faraday-detailed_logger', require: 'faraday/detailed_logger'

  gem 'spring'
  gem 'listen'
  gem 'spring-watcher-listen'
end

group :doc do
  gem 'redcarpet'
  gem 'yard', require: nil
end

group :test do
  # SPECS
  gem 'rspec-rails'
  gem 'rails-controller-testing'

  # ISOLATION
  gem 'database_cleaner'
  gem 'timecop'
  gem 'webmock'
  gem 'fakefs', require: 'fakefs/safe'

  # FACTORIES
  gem 'factory_girl_rails'
  gem 'ffaker'
end
