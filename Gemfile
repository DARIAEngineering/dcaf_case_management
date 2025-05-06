source 'https://rubygems.org'
ruby '3.2.4'

# Standard rails
gem 'rails', '~> 7.2.2.1'
gem 'puma', '~> 6.6' # roar
gem 'sdoc', '~> 2.6.0', group: :doc
gem 'nokogiri', '>= 1.13.4'
gem 'tzinfo-data', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'rexml' # not a ruby default in 3, but a requirement of bootsnap
gem 'matrix' # for compat reasons, required in builds

# Temporary compat gems until a new mail gem is released/rails 7 rolls out - see https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp
gem 'net-pop', require: false # for compat reasons, required in builds
gem 'net-imap', require: false # for compat reasons, required in builds
gem 'net-smtp', require: false # for compat reasons, required in builds

# Asset pipeline
gem 'sprockets-rails'
gem 'jsbundling-rails'
gem 'cssbundling-rails'
gem 'bootstrap_form', '~> 4.5.0'

# Our database is postgres
gem 'pg', '~> 1.5'
gem 'paper_trail', '~> 16.0'
gem 'activerecord-session_store'

# Our authentication library is devise, with oauth2 for google signin
gem 'devise', '~> 4.9'
gem 'devise-security'
gem 'omniauth-google-oauth2', '~> 1.2.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0'

# Run multiple funds on one server
gem 'acts_as_tenant', '~> 0.6'

# Strong Password for user password validation for folks not on oauth
gem 'strong_password', '~> 0.0.10'

# We report errors with sentry
gem 'sentry-ruby'
gem 'sentry-rails'

# Security libraries
gem 'rack-attack', '~> 6.7.0'

# For pagination
gem 'kaminari', '~> 1.2'

# For multi-step forms
gem 'wicked'

# Twilio Verify
gem 'twilio-ruby'

# Specific useful stuff
gem 'render_async', '~> 2.1' # load slow partials asynchronously
gem 'prawn' # pledge pdf generation
gem 'geokit' # clinic_finder service lat-lng
gem 'state_geo_tools' # state list
gem 'httparty' # easier http calls
gem 'view_component', '~> 3.21' # build reusable & encapsulated view components in Ruby
gem 'i18n-js', '~> 4.2' # Export i18n translations to JSON

# Stuff that we're targeting removal of
gem 'figaro' # we handle secrets differently now

# Stuff we're hardsetting because of security concerns
gem 'loofah', '>= 2.3.1'
gem 'rails-html-sanitizer', '>= 1.4.3'

group :development do
  gem 'i18n-tasks', '~> 1.0.15' # check and clean i18n keys
  gem 'rails-i18n', '~> 7.0' # dependency of i18n-tasks
  gem 'shog' # makes rails s output color!
  gem 'listen', '>= 3.0.5'
  gem 'rubocop', require: false # our code style / linting system
  gem 'rubocop-rails', require: false

  # Security scanners that also run in CI. They run with bundle exec.
  gem 'ruby_audit', require: false #
  gem 'bundler-audit', require: false

  # Run jsbundling and cssbundling along with rails via bin/dev and Procfile.dev
  gem 'foreman'
end

group :development, :test do
  gem 'pry' # pop `pry` in controller code to open up an IRB terminal
  gem 'byebug' # pop `byebug` in view code for open up an IRB terminal
  gem 'dotenv-rails' # used to set up our db ENV values
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
  gem 'capybara-lockstep'
  gem 'capybara-screenshot'
  gem 'launchy' # open up capybara screenshots automatically with `save_and_open_screenshot`

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
