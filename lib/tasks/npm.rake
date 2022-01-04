# frozen_string_literal: true

namespace :npm do
  desc 'Run npm install.'
  task install: :environment do
    system('npm install')
  end

  desc 'Run npm start.'
  task start: :environment do
    system('npm run start')
  end

  desc 'Run npm test.'
  task test: :environment do
    system('npm run test')
  end

  desc 'Run npm test_ci for continuous integration (i.e. only one run without autowatch).'
  task test_ci: :environment do
    system('npm run test_ci')
  end

  desc 'Run npm lint.'
  task lint: :environment do
    system('npm run lint')
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
