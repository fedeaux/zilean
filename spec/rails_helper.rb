ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

require 'factory_girl_rails'
require "capybara/rspec"
require 'capybara-screenshot/rspec'
require 'simplecov'

SimpleCov.start 'rails'

Dir.glob('spec/support/**/*.rb') { |f| require_relative f.split('/')[1..-1].join('/') }

Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.include FactoryGirl::Syntax::Methods
  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Capybara::DSL

  config.before :suite do
    Warden.test_mode!
    DatabaseCleaner.strategy = :truncation, {:except => %w[]}
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
