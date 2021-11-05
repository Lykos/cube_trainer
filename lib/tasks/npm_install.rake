# frozen_string_literal: true

desc 'Run npm install in the client directory.'
task npm_install: :environment do
  Dir.chdir(Rails.root.join('client')) { system('npm install') }
end
