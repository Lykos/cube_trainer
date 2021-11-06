# frozen_string_literal: true

namespace :npm do
  desc 'Run npm install in the client directory.'
  task install: :environment do
    system('npm install')
  end

  desc 'Run ng build to populate the public/ directory.'
  task build: :environment do
    system('npm run build')
  end

  # TODO: forward configuration from environment.
  desc 'Run ng build to populate the public/ directory.'
  task build_development: :environment do
    system('npm run build --configuration development')
  end
end

# Hack to not use the assets pipeline but our custom ng build instead.
Rake::Task['assets:precompile'].clear
