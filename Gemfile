source 'https://rubygems.org'
ruby '2.4.1'

gem 'rails', '>= 5.0.0', '< 5.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks', '2.5.3'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'bootstrap_form'
gem 'bootstrap_form-datetimepicker'
gem 'devise', '~> 4.2.1'
gem 'omniauth-google-oauth2'
gem 'mongoid', '6.1.0'
gem 'mongoid-history', '0.6.1'
gem 'mongoid_userstamp', git: 'https://github.com/DarthHater/mongoid_userstamp.git', branch: 'master'
gem 'mongo_session_store-rails4', git: 'https://github.com/drgcms/mongo_session_store.git', branch: 'rails5'
gem 'mongoid-enum', git: 'https://github.com/DarthHater/mongoid-enum', branch: 'master'
gem 'bson_ext'
gem 'figaro'
gem 'gon', '~> 6.1.0'
gem 'nokogiri', '>= 1.7.1'
gem 'newrelic_rpm'
gem 'tzinfo-data', require: false
gem 'js-routes'
gem 'rack-attack', '~> 5.0.1'
gem 'rack-test', '~> 0.6.3', require: 'rack/test'
gem 'platform-api', git: 'https://github.com/jalada/platform-api', branch: 'master'
gem 'clinic_finder', '~> 0.0.1'
gem 'geokit'

group :development do
  gem 'pry'
  gem 'web-console', '~> 2.0'
  gem 'rubocop', require: false
  gem 'brakeman', require: false
  gem 'ruby_audit', require: false
  gem 'bundler-audit', require: false
  gem 'quality', '20.1.0', require: false
  gem 'derailed_benchmarks'
  gem 'stackprof'
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
