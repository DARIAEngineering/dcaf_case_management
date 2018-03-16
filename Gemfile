source 'https://rubygems.org'
ruby '2.4.3'

# Standard rails
gem 'rails', '>= 5.1'
gem 'puma' # roar
gem 'turbolinks', '~> 5.0.0'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'nokogiri', '>= 1.8.1'
gem 'tzinfo-data', require: false

# Asset pipeline
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'uglifier', '>= 3.2.0'
gem 'coffee-rails', '~> 4.2.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Our database is MongoDB
gem 'mongoid', '>= 6.2.0', '< 7'
gem 'bson_ext'
gem 'mongoid-history', '0.6.1' # gives us object history
gem 'mongoid_userstamp', git: 'https://github.com/DCAFEngineering/mongoid_userstamp.git',
                         branch: 'master' # adds created_by and updated_by timestamps
gem 'mongo_session_store', '>= 3.1.0' # stores sessions in database for security
gem 'enumerize' # Mongoid doesn't have enum out of the box, so we get it here

# Our authentication library is devise, with oauth2 for google signin
gem 'devise', '~> 4.3.0'
gem 'omniauth-google-oauth2', '0.2.1' # TODO upgrade
gem 'omniauth-oauth2', '1.3.1' # TODO remove this pin

# We use `bootstrap_form_for` in views
gem 'bootstrap_form'

# Security libraries
gem 'rack-attack', '~> 5.0.1'
gem 'secure_headers', '~> 3.6', '>= 3.6.4'
gem 'kaminari-mongoid'
gem 'kaminari'


# Specific useful stuff
gem 'render_async', '~> 0.2.3' # load slow partials asynchronously
gem 'prawn' # pledge pdf generation
gem 'clinic_finder', git: 'https://github.com/DCAFEngineering/clinic_finder.git',
                     branch: 'master' # powers our clinic finder search

# Stuff that we're targeting removal of
gem 'figaro' # we handle secrets differently now
gem 'gon', '~> 6.1.0' # render async does this better
gem 'geokit' # should be included in clinic_finder instead of here
gem 'js-routes' # Not sure if this is used anymore
gem 'bootstrap_form-datetimepicker' # not sure if this is used anymore

group :development do
  gem 'shog' # makes rails s output color!
  gem 'listen' # used by systemtests
  gem 'rubocop', require: false # our code style / linting system

  # Security scanners that also run in CI
  gem 'brakeman', require: false
  gem 'ruby_audit', require: false
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
  gem 'mini_backtrace' # settle down minitest output
  gem 'pdf-inspector', require: 'pdf/inspector' # test pdf contents
  gem 'minitest-stub-const'
  gem 'rack-test', '~> 0.6.3', require: 'rack/test' # needed to test rack-attack
end

group :production do
  gem 'skylight' # our newrelic-style efficiency monitoring platform
  gem 'sqreen' # an active security monitoring platform
end
