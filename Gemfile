source 'https://rubygems.org'
ruby '3.0.2'

# Standard rails
gem 'rails', '~> 6.1.4'
gem 'puma', '~> 5.4' # roar
gem 'sdoc', '~> 2.3.0', group: :doc
gem 'nokogiri', '>= 1.13.2'
gem 'tzinfo-data', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'rexml' # not a ruby default in 3, but a requirement of bootsnap
gem 'net-smtp', require: false # For compat reasons, can remove after rails 7

# Asset pipeline
gem 'webpacker', '~> 5.4'
gem 'sass-rails', '>= 6'
gem 'bootstrap', '~> 4.5', '< 5' # we're on bs4 for now
gem 'bootstrap_form', '~> 4.5.0'
gem 'coffee-rails', '~> 5.0.0'
gem 'jquery-rails', '~> 4.4.0'
gem 'jquery-ui-rails'

# Our database is postgres
gem 'pg', '~> 1.2'
gem 'paper_trail', '~> 12.0'
gem 'activerecord-session_store'

# Our authentication library is devise, with oauth2 for google signin
gem 'devise', '~> 4.8'
gem 'omniauth-google-oauth2', '~> 1.0.0'
gem "omniauth-rails_csrf_protection", '~> 1.0'

# Run multiple funds on one server
gem 'acts_as_tenant', '~> 0.5.0'

# Strong Password for user password validation for folks not on oauth
gem 'strong_password', '~> 0.0.10'

# We report errors with sentry
gem 'sentry-ruby'
gem 'sentry-rails'

# Security libraries
gem 'rack-attack', '~> 6.6.0'

# For pagination
gem 'kaminari', '~> 1.2'

# Specific useful stuff
gem 'render_async', '~> 2.1' # load slow partials asynchronously
gem 'prawn' # pledge pdf generation
gem 'geokit' # clinic_finder service lat-lng
gem 'state_geo_tools' # state list 

# Stuff that we're targeting removal of
gem 'figaro' # we handle secrets differently now
gem 'js-routes', '1.4.9' # Not sure if this is used anymore

# Stuff we're hardsetting because of security concerns
gem 'loofah', '>= 2.3.1'
gem 'rails-html-sanitizer', '>= 1.0.4'

group :development do
  gem 'i18n-tasks', '~> 1.0.0' # check and clean i18n keys
  gem 'rails-i18n', '~> 6.0' # dependency of i18n-tasks, hardset to a rails-6-compat version
  gem 'shog' # makes rails s output color!
  gem 'listen', '>= 3.0.5', '< 3.8' # used by systemtests, hardset rails 6 compat
  gem 'rubocop', require: false # our code style / linting system
  gem 'rubocop-rails', require: false

  # Security scanners that also run in CI. They run with bundle exec.
  gem 'ruby_audit', require: false #
  gem 'bundler-audit', require: false
end

group :development, :test do
  gem 'pry' # pop `pry` in controller code to open up an IRB terminal
  gem 'byebug' # pop `byebug` in view code for open up an IRB terminal
  gem 'dotenv-rails' #used to set up our db ENV values
  gem 'bullet' # yell if n+1 queries
end

group :test do
  # Useful minitest tools
  gem 'minitest-spec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'timecop'

  # Systemtest related tools
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'capybara-screenshot'
  gem 'launchy' # open up capybara screenshots automatically with `save_and_open_screenshot`
  gem 'webdrivers'

  # Test coverage related libraries
  gem 'simplecov', require: false

  # Specifics
  gem 'shoulda-context'
  gem 'minitest-optional_retry' # retry flaky tests 3 times
  gem 'mini_backtrace' # settle down minitest output
  gem 'pdf-inspector', require: 'pdf/inspector' # test pdf contents
  gem 'minitest-stub-const'
  gem 'rack-test', '>= 0.6.3', require: 'rack/test' # needed to test rack-attack
end

group :production do
  gem 'sqreen' # an active security monitoring platform
end
