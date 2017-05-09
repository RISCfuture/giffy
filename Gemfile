source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# FRAMEWORK
gem 'rails', '5.1.1'
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
gem 'webpacker'
gem 'uglifier'
gem 'therubyracer', platforms: :ruby
gem 'sprockets-es6', require: 'sprockets/es6'
gem 'turbolinks'
gem 'sprockets-es6', require: 'sprockets/es6'
# JSON
gem 'jbuilder'

# JOBS
gem 'sidekiq'

# API
gem 'addressable'
gem 'faraday'
gem 'json'
gem 'nokogiri'

# LATEX
gem 'aws-sdk'

# COMIC SANS
gem 'prawn'

group :development do
  gem 'puma'
  gem 'listen'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'faraday-detailed_logger', require: 'faraday/detailed_logger'
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

group :production do
  # CACHING
  gem 'redis-rails'
  gem 'rack-cache', require: 'rack/cache'
end
