source 'https://rubygems.org'
ruby '2.7.2'

# Standard rails
gem 'rails', '~> 6.0.3.6'
gem 'puma', '~> 4.3' # roar
gem 'sdoc', '~> 1.0.0', group: :doc
gem 'nokogiri', '>= 1.11.1'
gem 'tzinfo-data', require: false
gem 'bootsnap', '>= 1.4.2', require: false

# Asset pipeline
gem 'webpacker', '~> 5.2'
gem 'sass-rails', '>= 6'
gem 'bootstrap', '~> 4.5.0'
gem 'bootstrap_form', '~> 4.5.0'
gem 'coffee-rails', '~> 5.0.0'
gem 'jquery-rails', '~> 4.3.4'
gem 'jquery-ui-rails'

# Our database is MongoDB
gem 'mongoid', '~> 7.0.0', '< 8'
gem 'bson_ext'
gem 'mongoid-history', '< 1.0' # gives us object history
gem 'mongoid_userstamp', git: 'https://github.com/DCAFEngineering/mongoid_userstamp.git',
                         branch: 'master' # adds created_by and updated_by timestamps
gem 'mongo_session_store', '>= 3.1.0' # stores sessions in database for security
gem 'enumerize' # Mongoid doesn't have enum out of the box, so we get it here
# gem 'mongoid_rails_migrations' # Mongoid also does not have migrations out of the box, so we get that here

# ...but hopefully soon it will be postgres
gem 'pg', '~> 1.2'
gem 'paper_trail', '~> 10.3'
gem 'paper_trail-globalid'

# Our authentication library is devise, with oauth2 for google signin
gem 'devise', '~> 4.7.3'
gem 'omniauth-google-oauth2', '~> 0.8.1'

# We report errors with sentry
gem 'sentry-raven'

# Security libraries
gem 'rack-attack', '~> 5.4.1'

# For pagination
gem 'kaminari-mongoid', '~> 1.0'
gem 'kaminari', '~> 1.2'

# Specific useful stuff
gem 'render_async', '~> 2.1' # load slow partials asynchronously
gem 'prawn' # pledge pdf generation
gem 'geokit' # clinic_finder service lat-lng
gem 'state_geo_tools' # state list 

# Stuff that we're targeting removal of
gem 'figaro' # we handle secrets differently now
gem 'js-routes' # Not sure if this is used anymore

# Stuff we're hardsetting because of security concerns
gem 'loofah', '>= 2.3.1'
gem 'rails-html-sanitizer', '>= 1.0.4'

group :development do
  gem 'i18n-tasks', '~> 0.9.29' # check and clean i18n keys
  gem 'rails-i18n', '~> 6.0' # dependency of i18n-tasks, hardset to a rails-6-compat version
  gem 'shog' # makes rails s output color!
  gem 'listen', '>= 3.0.5', '< 3.2' # used by systemtests, hardset rails 6 compat
  gem 'rubocop', require: false # our code style / linting system

  # Security scanners that also run in CI. They run with bundle exec.
  gem 'ruby_audit', require: false #
  gem 'bundler-audit', require: false
end

group :development, :test do
  gem 'pry' # pop `pry` in controller code to open up an IRB terminal
  gem 'byebug' # pop `byebug` in view code for open up an IRB terminal
  gem 'knapsack' # lets us split up our tets so they run faster in CI
  gem 'dotenv-rails' #used to set up our db ENV values
end

group :test do
  # Useful minitest tools
  gem 'minitest-spec-rails'
  gem 'minitest-ci'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
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
  gem 'codecov', require: false

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
