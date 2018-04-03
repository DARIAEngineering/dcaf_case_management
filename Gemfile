source 'https://rubygems.org'
ruby '2.4.3'

gem 'rails', '>= 5.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 3.2.0'
gem 'coffee-rails', '~> 4.2.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks', '~> 5.0.0'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'prawn'
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'bootstrap_form'
gem 'bootstrap_form-datetimepicker'
gem 'devise', '~> 4.3.0'
gem 'omniauth-google-oauth2', '0.2.1' # TODO upgrade
gem 'omniauth-oauth2', '1.3.1' # TODO remove this pin
gem 'mongoid', '>= 6.2.0', '< 7'
gem 'mongoid-history', '0.6.1'
gem 'mongoid_userstamp', git: 'https://github.com/DCAFEngineering/mongoid_userstamp.git', branch: 'master'
gem 'mongo_session_store', '>= 3.1.0'
gem 'enumerize'
gem 'bson_ext'
gem 'figaro'
gem 'render_async', '~> 0.2.3'
gem 'gon', '~> 6.1.0'
gem 'nokogiri', '>= 1.8.1'
gem 'tzinfo-data', require: false
gem 'js-routes'
gem 'rack-attack', '~> 5.0.1'
gem 'rack-test', '~> 0.6.3', require: 'rack/test'
gem 'clinic_finder', git: 'https://github.com/DCAFEngineering/clinic_finder.git', branch: 'master'
gem 'geokit'
gem 'secure_headers', '~> 3.6', '>= 3.6.4'

group :development do
  gem 'pry'
  gem 'listen'
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'ruby_audit', require: false
  gem 'bundler-audit', require: false
  # gem 'dawnscanner', require: false # disable until dawnscanner fixes CD prob
end

group :development, :test do
  gem 'byebug'
  gem 'spring'
  gem 'knapsack'
end

group :test do
  gem 'shoulda-context'
  gem 'mini_backtrace'
  gem 'minitest-spec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'launchy'
  gem 'codecov', require: false
  gem 'timecop'
  gem 'capybara-screenshot'
  gem 'pdf-inspector', require: "pdf/inspector"
  gem 'minitest-stub-const'
end

group :production do
  gem 'puma'
  gem 'skylight'
  gem 'sqreen'
end
