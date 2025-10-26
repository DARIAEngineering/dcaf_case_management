source "https://rubygems.org"
ruby "3.4.4"

# Rails standards
gem "rails", "~> 8.1.0"
gem "pg", "~> 1.1" # Use postgresql as the database for Active Record
gem "propshaft" # The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "puma", ">= 5.0" # Use the Puma web server [https://github.com/puma/puma]
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "kamal", require: false # Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "thruster", require: false # Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
# gem "bcrypt", "~> 3.1.7" # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "jbuilder" # Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "tzinfo-data", platforms: %i[ windows jruby ] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

# Assets
gem "importmap-rails" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "turbo-rails" # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "stimulus-rails" # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "cssbundling-rails" # Bundle and process CSS [https://github.com/rails/cssbundling-rails]
# gem "image_processing", "~> 1.2" # Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]

# Async work
# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem "solid_cache"
# gem "solid_queue"
# gem "solid_cable"

# Custom production gems under here
gem 'acts_as_tenant', '~> 1.0' # Run multiple funds on one server
gem 'paper_trail', '~> 17.0' # Changelog
gem 'csv'
gem 'geokit' # clinic_finder service lat-lng
gem 'state_geo_tools' # list of states as a handy constant
gem 'sentry-ruby' # sentry for alerting
gem 'sentry-rails' # rails knowledge in sentry
gem 'bootstrap_form', '~> 5.4'

# Auth
gem 'devise', '~> 4.9' # Auth system
gem 'omniauth-google-oauth2', '~> 1.2.1' # Enabling sign in with google
gem 'devise-security'
# gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'strong_password', '~> 0.0.10' # Strong Password for user password validation for folks not on oauth
gem 'activerecord-session_store'

group :development, :test do
  # Rails standards
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "brakeman", require: false # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "rubocop-rails-omakase", require: false # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]

  # Custom gems under here
  gem 'factory_bot_rails'
end

group :development do
  # Rails standards
  gem "web-console" # Use console on exceptions pages [https://github.com/rails/web-console]

  # Custom gems under here
end

group :test do
  # Rails standards
  gem "capybara" # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "selenium-webdriver"

  # Custom gems under here
end


# # Old gemfile
# # source 'https://rubygems.org'
# ruby '3.2.4'

# # Standard rails
# gem 'rails', '~> 7.2.2.1'
# gem 'puma', '~> 6.6' # roar
# gem 'sdoc', '~> 2.6.0', group: :doc
# gem 'nokogiri', '>= 1.13.4'
# gem 'tzinfo-data', require: false
# gem 'bootsnap', '>= 1.4.2', require: false
# gem 'rexml' # not a ruby default in 3, but a requirement of bootsnap
# gem 'matrix' # for compat reasons, required in builds

# # Temporary compat gems until a new mail gem is released/rails 7 rolls out - see https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp
# gem 'net-pop', require: false # for compat reasons, required in builds
# gem 'net-imap', require: false # for compat reasons, required in builds
# gem 'net-smtp', require: false # for compat reasons, required in builds

# # Asset pipeline
# gem 'sprockets-rails'
# gem 'jsbundling-rails'
# gem 'cssbundling-rails'

# # Our database is postgres
# gem 'pg', '~> 1.5'
# gem 'paper_trail', '~> 16.0'
# gem 'activerecord-session_store'

# # Our authentication library is devise, with oauth2 for google signin
# gem 'devise', '~> 4.9'
# gem 'devise-security'
# gem 'omniauth-google-oauth2', '~> 1.2.1'
# gem 'omniauth-rails_csrf_protection', '~> 1.0'

# # Run multiple funds on one server
# gem 'acts_as_tenant', '~> 0.6'

# # Strong Password for user password validation for folks not on oauth
# gem 'strong_password', '~> 0.0.10'

# # We report errors with sentry

# # Security libraries
# gem 'rack-attack', '~> 6.7.0'

# # For pagination
# gem 'kaminari', '~> 1.2'

# # For multi-step forms
# gem 'wicked'

# # Twilio Verify
# gem 'twilio-ruby'

# # Specific useful stuff
# gem 'render_async', '~> 2.1' # load slow partials asynchronously
# gem 'prawn' # pledge pdf generation
# gem 'geokit' # clinic_finder service lat-lng
# gem 'httparty' # easier http calls
# gem 'view_component', '~> 3.22' # build reusable & encapsulated view components in Ruby
# gem 'i18n-js', '~> 4.2' # Export i18n translations to JSON

# # Stuff that we're targeting removal of
# gem 'figaro' # we handle secrets differently now

# # Stuff we're hardsetting because of security concerns
# gem 'loofah', '>= 2.3.1'
# gem 'rails-html-sanitizer', '>= 1.4.3'

# group :development do
#   gem 'i18n-tasks', '~> 1.0.15' # check and clean i18n keys
#   gem 'rails-i18n', '~> 7.0' # dependency of i18n-tasks
#   gem 'shog' # makes rails s output color!
#   gem 'listen', '>= 3.0.5'
#   gem 'rubocop', require: false # our code style / linting system
#   gem 'rubocop-rails', require: false

#   # Security scanners that also run in CI. They run with bundle exec.
#   gem 'ruby_audit', require: false #
#   gem 'bundler-audit', require: false

#   # Run jsbundling and cssbundling along with rails via bin/dev and Procfile.dev
#   gem 'foreman'
# end

# group :development, :test do
#   gem 'pry' # pop `pry` in controller code to open up an IRB terminal
#   gem 'byebug' # pop `byebug` in view code for open up an IRB terminal
#   gem 'dotenv-rails' # used to set up our db ENV values
#   gem 'bullet' # yell if n+1 queries
# end

# group :test do
#   # Useful minitest tools
#   gem 'minitest-spec-rails'
#   gem 'factory_bot_rails'
#   gem 'faker'
#   gem 'timecop'

#   # Systemtest related tools
#   gem 'capybara'
#   gem 'selenium-webdriver'
#   gem 'capybara-screenshot'
#   gem 'launchy' # open up capybara screenshots automatically with `save_and_open_screenshot`

#   # Test coverage related libraries
#   gem 'simplecov', require: false

#   # Specifics
#   gem 'shoulda-context'
#   gem 'minitest-optional_retry' # retry flaky tests 3 times
#   gem 'mini_backtrace' # settle down minitest output
#   gem 'pdf-inspector', require: 'pdf/inspector' # test pdf contents
#   gem 'minitest-stub-const'
#   gem 'rack-test', '>= 0.6.3', require: 'rack/test' # needed to test rack-attack
# end
