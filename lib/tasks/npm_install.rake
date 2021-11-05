desc 'Run npm install in the client directory.'
task :npm_install do
  Dir.chdir(Rails.root.join("client")) { system("npm install") }
end
