source 'https://rubygems.org'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'

# Database
gem 'pg', '~> 0.18'

# Utility
gem 'listen'
gem 'string-urlize'
gem 'seedbank'
gem 'dotenv-rails'

# Modeling
gem 'ancestry'
gem 'devise'

# CSS Framework
gem 'therubyracer'
gem 'less-rails-semantic_ui'

# Frontend
gem "bower-rails", "~> 0.10.0"
gem 'angularjs-rails'
gem 'coffee-rails', '~> 4.2'
gem 'compass-rails'
gem 'haml-rails'
gem 'highcharts-rails'
gem 'jquery-rails'
gem 'momentjs-rails'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'sprockets', '~> 3.6.3'

# REST
gem 'rabl'

# Server
gem 'puma', '~> 3.0'

# Console
gem 'table_print'
gem 'awesome_print'
gem 'text-table'
gem 'pry'

group :development, :test do
  gem 'byebug'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'database_cleaner', :git => 'git://github.com/bmabey/database_cleaner.git'
  gem 'factory_girl_rails'
  gem 'email_spec'
  gem 'cucumber-rails', require: false
  gem 'simplecov', :require => false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'web-console'

  gem 'capistrano'
  gem 'capistrano3-puma'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm'
  gem 'capistrano-rails-console'
end

group :production do
  gem 'rails_12factor' # heroku
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
