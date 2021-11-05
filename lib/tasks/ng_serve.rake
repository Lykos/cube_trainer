# frozen_string_literal: true

desc 'Run ng serve to continuosly recompile and serve the frontend.'
task ng_serve: :environment do
  Dir.chdir(Rails.root.join('client')) { system('ng serve') }
end
