# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.3.0'

# Reduces boot times through caching; required in config/boot.rb
# Without this, no commands work, so we need it everywhere.
gem 'bootsnap', '>= 1.4.2', require: false

# This group contains all dependencies that are needed to run the Rails backend.
# They are needed for the backend independent of the environment.
group :development, :test, :production do
  # For authentication
  gem 'devise', '~>4.9.4'
  gem 'devise_token_auth', '~>1.2.2'
  gem 'omniauth-apple'
  gem 'omniauth-facebook'
  gem 'omniauth-github'
  gem 'omniauth-google-oauth2'
  gem 'omniauth-twitter'

  gem 'rack-cors', '~> 2.0.2', require: 'rack/cors'

  # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
  gem 'rails', '~> 7.0'

  # Core cubing related functionality.
  gem 'twisty_puzzles', '>= 0.0.44'

  # Database access. TODO: figure out whether this is still needed now that this project uses rails.
  gem 'activerecord', '~> 7.0'

  # Postgresql support.
  gem 'pg', '~> 1.5.6'

  gem 'ruby-filemagic'

  gem 'active_model_serializers'
end

group :development, :test do
  gem 'rspec-rails'

  gem 'colorize'
  gem 'parallel'
  gem 'ruby-progressbar'
  gem 'rubyzip'
  gem 'wombat'
  gem 'xdg'
end

group :development, :client, :test do
  gem 'rake'
end

group :development, :production do
  # Use Puma as the app server
  gem 'puma', '~> 6.4'

  # Pry is needed to inspect the production state via rails console.
  gem 'pry'

  gem 'google-api-client'
  gem 'googleauth'
end

group :production do
  # Use Redis adapter to run Action Cable in production
  gem 'redis', '~> 5.2'
end

group :development do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.10'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'

  gem 'simplecov', require: false
end

group :rubocop do
  gem 'rubocop', '~> 1.63.2', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', '~> 2.24.1', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', '~> 2.29.1', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.39'
  gem 'selenium-webdriver', '~> 4.19.0'

  gem 'rantly'
  gem 'rspec'
  gem 'rspec-prof'
end
