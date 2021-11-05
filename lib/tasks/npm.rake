# frozen_string_literal: true

namespace :npm do
  desc 'Run npm install in the client directory.'
  task install: :environment do
    Dir.chdir(Rails.root.join('client')) { system('npm install') }
  end
end
