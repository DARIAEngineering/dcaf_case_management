source 'https://rubygems.org'
ruby '2.5.1'

# Standard rails
gem 'rails', '>= 5.1'
gem 'puma' # roar
gem 'turbolinks', '~> 5.2.0'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 1.0.0', group: :doc
gem 'nokogiri', '>= 1.8.5'
gem 'tzinfo-data', require: false

# Asset pipeline
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'uglifier', '~> 4.1'
gem 'coffee-rails', '~> 4.2.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Our database is MongoDB
gem 'mongoid', '>= 6.2.0', '< 7'
gem 'bson_ext'
gem 'mongoid-history', '< 1.0' # gives us object history
gem 'mongoid_userstamp', git: 'https://github.com/DCAFEngineering/mongoid_userstamp.git',
                         branch: 'master' # adds created_by and updated_by timestamps
gem 'mongo_session_store', '>= 3.1.0' # stores sessions in database for security
gem 'enumerize' # Mongoid doesn't have enum out of the box, so we get it here

# Our authentication library is devise, with oauth2 for google signin
gem 'devise', '~> 4.5'
gem 'omniauth-google-oauth2', '0.5.3'

# We use `bootstrap_form_for` in views
gem 'bootstrap_form'

# Security libraries
gem 'rack-attack', '~> 5.4.1'
gem 'secure_headers', '~> 6.0.0'

# For pagination
gem 'kaminari-mongoid', '~> 1.0'
gem 'kaminari', '~> 1.1'

# Specific useful stuff
gem 'render_async', '< 2.0' # load slow partials asynchronously
gem 'prawn' # pledge pdf generation

# Stuff that we're targeting removal of
gem 'figaro' # we handle secrets differently now
gem 'gon', '~> 6.1.0' # render async does this better
gem 'geokit' # should be included in clinic_finder instead of here
gem 'js-routes' # Not sure if this is used anymore
gem 'bootstrap_form-datetimepicker' # not sure if this is used anymore

# Stuff we're hardsetting because of security concerns
gem 'loofah', '>= 2.2.1'
gem 'rails-html-sanitizer', '>= 1.0.4'

group :development do
  gem 'shog' # makes rails s output color!
  gem 'listen' # used by systemtests
  gem 'rubocop', require: false # our code style / linting system

  # Security scanners that also run in CI. They run with bundle exec.
  gem 'ruby_audit', require: false #
  gem 'bundler-audit', require: false
end

group :development, :test do
  gem 'pry' # pop `pry` in controller code to open up an IRB terminal
  gem 'byebug' # pop `byebug` in view code for open up an IRB terminal
  gem 'spring'
  gem 'knapsack' # lets us split up our tets so they run faster in CI
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

  # Test coverage related libraries
  gem 'simplecov', require: false
  gem 'codecov', require: false

  # Specifics
  gem 'shoulda-context'
  gem 'minitest-optional_retry' # retry flaky tests 3 times
  gem 'mini_backtrace' # settle down minitest output
  gem 'pdf-inspector', require: 'pdf/inspector' # test pdf contents
  gem 'minitest-stub-const'
  gem 'rack-test', '~> 0.6.3', require: 'rack/test' # needed to test rack-attack
end

group :production do
  gem 'skylight' # our newrelic-style efficiency monitoring platform
  gem 'sqreen' # an active security monitoring platform
end
