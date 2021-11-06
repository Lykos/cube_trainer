# frozen_string_literal: true

namespace :npm do
  desc 'Run npm install in the client directory.'
  task install: :environment do
    system('npm install')
  end

  desc 'Run ng build to populate the public/ directory.'
  task build: :environment do
    typescript_config = Rails.env.production? ? 'production' : 'development'
    system("npm build --configuration #{typescript_config}")
  end
end

# Hack to not use the assets pipeline but our custom ng build instead.
Rake::Task['assets:precompile'].clear
namespace :assets do
  task precompile: ['npm:install', 'npm:build'] do
    # Don't do anything, the ng:build task does what we want.
  end
end
