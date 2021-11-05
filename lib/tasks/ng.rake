# frozen_string_literal: true

# ng_command is a command like "ng build". Note that "ng" needs to be included.
def run_ng(ng_command)
  Dir.chdir(Rails.root.join('client')) { system("PATH=$(npm bin):$PATH #{ng_command}") }
end

namespace :ng do
  desc 'Run ng build to populate the public/ directory.'
  task build: :environment do
    run_ng('ng build --configuration development')
  end

  desc 'Run ng serve to continuosly recompile and serve the frontend.'
  task serve: :environment do
    run_ng('ng serve')
  end

  desc 'Run ng test to run all angular tests.'
  task test: :environment do
    run_ng('ng test')
  end
end
