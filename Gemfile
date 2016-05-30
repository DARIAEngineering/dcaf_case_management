source 'https://rubygems.org'

gem 'rails', '4.2.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'devise', '~> 3.5', '>= 3.5.2'
gem 'mongoid', '~> 5.0.0'
gem 'mongoid-history', '~> 0.5.0'
gem 'mongoid_userstamp'
gem 'bson_ext'
gem 'figaro'
gem 'bootstrap_form'
gem 'bootstrap_form-datetimepicker'

group :development do
  gem 'web-console', '~> 2.0'
  gem 'rubocop', require: false
end

group :development, :test do
  gem 'byebug'
  gem 'spring'

  # better error handling
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'minitest-reporters'
  gem 'mini_backtrace'
  gem 'minitest-spec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'simplecov', require: false
end

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end
