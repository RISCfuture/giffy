source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# FRAMEWORK
gem 'rails', '5.1.4'
gem 'configoro'

# MODELS
gem 'pg', '< 1.0'
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
gem 'turbolinks'
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
gem 'aws-sdk-s3'

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
  gem 'factory_bot_rails'
  gem 'ffaker'
end

group :production do
  # CACHING
  gem 'redis-rails'
  gem 'rack-cache', require: 'rack/cache'
end
