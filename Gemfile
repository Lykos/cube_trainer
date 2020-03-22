# frozen_string_literal: true

source 'https://rubygems.org' do
  gem 'activerecord'
  gem 'colorize'
  gem 'parallel'
  gem 'ruby-filemagic'
  gem 'ruby-progressbar'
  gem 'rubyzip'
  gem 'sqlite3'
  gem 'wombat'
  gem 'xdg'

  group :development, :test do
    gem 'rake'
  end
  group :development do
    gem 'rake-compiler'
    gem 'rubocop', '>=0.80'
    gem 'rubocop-performance', require: false
    gem 'rubocop-rake', require: false
  end
  group :test do
    gem 'rantly'
    gem 'rspec'
    gem 'rspec-prof'
    gem 'simplecov', require: false
  end
  group :ui do
    gem 'qtbindings'
  end
end
