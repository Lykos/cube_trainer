# frozen_string_literal: true

desc 'Run ng build to populate the public/ directory.'
task ng_build: :environment do
  Dir.chdir(Rails.root.join('client')) { system('ng build --configuration development') }
end
