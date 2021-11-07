# frozen_string_literal: true

namespace :npm do
  desc 'Run npm install in the client directory.'
  task install: :environment do
    system('npm install')
  end

  desc 'Run ng build to populate the public/ directory.'
  task build: :environment do
    # TODO: forward development vs production better.
    if Rails.env.production?
      system('npm run build')
    else
      system('npm run build_development')
    end
  end
end

# Hack to not use the assets pipeline but our custom ng build instead.
Rake::Task['assets:precompile'].clear
