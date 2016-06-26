source 'https://rubygems.org'
ruby '2.2.4'

gem 'rails', '~> 4.2.6'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'devise', '~> 3.5', '>= 3.5.10'
gem 'mongoid', '~> 5.0.0'
gem 'mongoid-history', '~> 0.5.0'
gem 'mongoid_userstamp'
gem 'bson_ext'
gem 'figaro'
gem 'bootstrap_form'
gem 'bootstrap_form-datetimepicker'
gem 'quality', require: false
gem 'nokogiri', '>= 1.6.8'
gem 'newrelic_rpm'

group :development do
  gem 'web-console', '~> 2.0'
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'ruby_audit', require: false
  gem 'bundler-audit', require: false
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
  gem 'poltergeist'
  gem 'simplecov', require: false
  gem 'launchy'
  gem 'codecov', require: false
  gem 'timecop'
end

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end
