source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# FRAMEWORK
gem 'bootsnap'
gem 'configoro'
gem 'rails', '5.2.2'

# MODELS
gem 'find_or_create_on_scopes'
gem 'pg', '< 1.0'
gem 'url_validation'

# VIEWS
gem 'sprockets-rails'
# HTML
gem 'slim-rails'
# CSS
gem 'autoprefixer-rails'
gem 'sass-rails'
# JS
gem 'turbolinks'
gem 'uglifier'
gem 'webpacker'
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
  gem 'listen'
  gem 'puma'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'faraday-detailed_logger', require: 'faraday/detailed_logger'
end

group :doc do
  gem 'redcarpet'
  gem 'yard', require: false
end

group :test do
  # SPECS
  gem 'rails-controller-testing'
  gem 'rspec-rails'

  # ISOLATION
  gem 'database_cleaner'
  gem 'fakefs', require: 'fakefs/safe'
  gem 'timecop'
  gem 'webmock'

  # FACTORIES
  gem 'factory_bot_rails'
  gem 'ffaker'
end

group :production do
  # CACHING
  gem 'redis'
end
