require 'cucumber/rails'
require 'capybara-screenshot/cucumber'

ActionController::Base.allow_rescue = false

include FactoryGirl::Syntax::Methods
include Warden::Test::Helpers
require_relative '../../spec/support/factory_girl_extensions.rb'

begin
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Cucumber::Rails::Database.javascript_strategy = :truncation

Capybara.default_driver = :webkit

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end
