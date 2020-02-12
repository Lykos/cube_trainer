# frozen_string_literal: true

source 'https://rubygems.org' do
  gem 'colorize'
  gem 'parallel'
  gem 'ruby-filemagic'
  gem 'ruby-progressbar'
  gem 'rubyzip'
  gem 'sqlite3'
  gem 'xdg'

  group :development do
    # Rake would be here as well, but it's in group test.
    gem 'rake-compiler'
    gem 'rubocop'
  end
  group :test do
    gem 'rake', group: :development
    gem 'rantly'
    gem 'rspec'
    gem 'rspec-prof'
    gem 'simplecov', require: false
  end
  group :ui do
    gem 'qtbindings'
  end
end
