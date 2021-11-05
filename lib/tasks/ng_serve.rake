desc 'Run ng serve to continuosly recompile and serve the frontend.'
task :ng_serve do
  Dir.chdir(Rails.root.join("client")) { system("ng serve") }
end
