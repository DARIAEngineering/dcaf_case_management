source 'https://rubygems.org'
ruby '2.3.3'

gem 'rails', '~> 4.2.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
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
gem 'gon', '~> 6.1.0'
gem 'bootstrap_form'
gem 'bootstrap_form-datetimepicker'
gem 'nokogiri', '>= 1.6.8'
gem 'newrelic_rpm'
gem 'mongo_session_store-rails4'
gem 'mongoid-enum'
gem 'tzinfo-data', require: false
gem 'js-routes'
gem "omniauth-google-oauth2", "~> 0.2.1"
gem 'rack-attack', '~> 5.0.1'
gem 'rack-test', '~> 0.6.3', require: 'rack/test'
gem 'platform-api', git: 'https://github.com/jalada/platform-api', branch: 'master'

group :development do
  gem 'pry'
  gem 'web-console', '~> 2.0'
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'ruby_audit', require: false
  gem 'bundler-audit', require: false
  gem 'quality', '20.1.0', require: false
  # gem 'dawnscanner', require: false # disable until dawnscanner fixes CD prob
end

group :development, :test do
  gem 'byebug'
  gem 'spring'

  # better error handling
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'shoulda-context'
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
  gem 'capybara-screenshot'
  gem 'minitest-ci'
end

group :production do
  gem 'puma'
  gem 'rails_12factor'
  gem 'letsencrypt-rails-heroku'
end
