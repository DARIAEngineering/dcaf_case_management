source 'https://rubygems.org'
ruby '3.4.8'

# Rails stock
gem 'rails', '~> 8.1' # temp 72 # Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
# gem "propshaft", require: false # temp off # The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "pg", "~> 1.6" # Use postgresql as the database for Active Record
gem "puma", '~> 7.1' # roar # Use the Puma web server [https://github.com/puma/puma]
# gem "importmap-rails" # Temp off # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem "turbo-rails" # Temp off # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "stimulus-rails" # Temp off # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "cssbundling-rails" # Temp off # Bundle and process CSS [https://github.com/rails/cssbundling-rails]
# gem "jbuilder" # Stays off, we don't need it # Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "bcrypt", "~> 3.1.7" # Stays off, we don't need it # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "tzinfo-data", platforms: %i[ windows jruby ] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "solid_cache" # Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_queue" # Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable" # Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "kamal", require: false # Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "thruster", require: false # Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "image_processing", "~> 1.2" # Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]

# Custom
# General utilities
gem 'acts_as_tenant', '~> 0.6' # Run multiple funds on one server
gem 'strong_password', '~> 0.0.10' # Strong Password for user password validation for folks not on oauth

gem 'state_geo_tools' # state list
gem 'kaminari', '~> 1.2' # For pagination
gem 'render_async', '~> 2.1' # load slow partials asynchronously
gem 'view_component', '~> 3.22' # build reusable & encapsulated view components in Ruby
gem 'i18n-js', '~> 4.2' # Export i18n translations to JSON

# Asset pipeline
gem 'sprockets-rails'
gem 'jsbundling-rails'
gem 'bootstrap_form', '~> 4.5.0'

# Our authentication library is devise, with oauth2 for google signin
gem 'devise', '~> 4.9'
gem 'devise-security'
gem 'omniauth-google-oauth2', '~> 1.2.1'
gem 'omniauth-rails_csrf_protection', '~> 2.0'

# Stuff we're hardsetting because of security concerns
gem 'loofah', '>= 2.3.1'
gem 'rails-html-sanitizer', '>= 1.4.3'
gem 'nokogiri', '>= 1.13.4'

# Postgres extensions
gem 'paper_trail', '~> 17.0'
gem 'activerecord-session_store'

# We report errors with sentry
gem 'sentry-ruby'
gem 'sentry-rails'

# Security libraries
gem 'rack-attack', '~> 6.8.0' # Prevent spammy stuff

# Clinic finder deps
gem 'geokit' # clinic_finder service lat-lng
gem 'httparty' # easier http calls

# MFA
gem 'wicked' # For multi-step forms
gem 'twilio-ruby' # For Twilio Verify

# Stuff that we're targeting removal of
gem 'figaro' # we handle secrets differently now
gem 'prawn' # pledge pdf generation


group :development, :test do
  # Rails stock
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude" # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "bundler-audit", require: false # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "brakeman", require: false # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "rubocop-rails-omakase", require: false # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]

  # Custom
  gem 'pry' # pop `pry` in controller code to open up an IRB terminal
  gem 'byebug' # pop `byebug` in view code for open up an IRB terminal
  gem 'dotenv-rails' # used to set up our db ENV values
  gem 'bullet' # yell if n+1 queries

  gem 'ruby_audit', require: false # Check for Ruby language vulnerabilities
end


group :development do
  # Rails stock
  gem "web-console" # Use console on exceptions pages [https://github.com/rails/web-console]

  # Custom
  gem 'i18n-tasks', '~> 1.1.2' # check and clean i18n keys
  gem 'rails-i18n', '~> 8.0' # dependency of i18n-tasks
  gem 'listen', '>= 3.0.5'

  gem 'foreman' # Run jsbundling and cssbundling along with rails via bin/dev and Procfile.dev
  gem 'shog' # makes rails s output color!
end


group :test do
  # Rails stock
  gem "capybara" # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "selenium-webdriver" # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]

  # Custom
  # Useful minitest tools
  gem 'minitest-spec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'timecop'

  # Specifics
  gem 'shoulda-context'
  gem 'minitest-optional_retry' # retry flaky tests 3 times
  gem 'mini_backtrace' # settle down minitest output
  gem 'pdf-inspector', require: 'pdf/inspector' # test pdf contents
  gem 'minitest-stub-const'
  gem 'rack-test', '>= 0.6.3', require: 'rack/test' # needed to test rack-attack
end
