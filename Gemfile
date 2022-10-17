# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use sqlite3 as the database for Active Record
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem 'kredis'

# This gem adds a Redis::Namespace class which can be used to namespace Redis keys. http://redis.io
gem 'redis-namespace'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# A simple API wrapper for Mixin Network in Ruby
gem 'trident_assistant', git: 'https://github.com/TheTridentOne/trident_assistant.git'

# The Rails way to serialize/deserialize objects with Message Pack.
gem 'msgpack_rails'

# Config helps you easily manage environment specific settings in an easy and usable manner.
gem 'config'

# Bundle and process CSS in Rails with Tailwind, PostCSS, and Sass via Node.js.
gem 'cssbundling-rails'

# Simple, efficient background processing for Ruby http://sidekiq.org
gem 'sidekiq', '~> 6.0'

# Scheduler / Cron for Sidekiq jobs
gem 'sidekiq-cron'

# Concurrency and threshold throttling for Sidekiq.
gem 'sidekiq-throttled'

# AASM - State machines for Ruby classes (plain Ruby, ActiveRecord, Mongoid)
gem 'aasm'

# The Best Pagination Ruby Gem
gem 'pagy'

# Object-based searching.
gem 'ransack', github: 'activerecord-hackery/ransack'

# S3 active storage service
gem 'aws-sdk-s3', require: false

# Notifications for Ruby on Rails applications
gem 'noticed'

# Use ActiveRecord transactional callbacks outside of models, literally everywhere in your application.
gem 'after_commit_everywhere'

# Rubyzip is a ruby library for reading and writing zip files.
gem 'rubyzip'

# A little bit of magic to make partials perfect for components.
gem 'nice_partials'

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Annotate Rails classes with schema and routes info
  gem 'annotate', require: false

  # A Ruby static code analyzer and formatter
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
