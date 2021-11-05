desc 'Run ng build to populate the public/ directory.'
task :ng_build do
  Dir.chdir(Rails.root.join("client")) { system("ng build --configuration development") }
end
