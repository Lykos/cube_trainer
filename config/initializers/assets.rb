# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css)

Rails.application.config.app_generators.javascript_engine :typescript

# Enable the asset pipeline
Rails.application.config.assets.enabled = true

Typescript::Rails::Compiler.default_options = [
  '--module', 'commonjs',
  '--target', 'ES5',
  '--moduleResolution', 'node',
  #'--sourceMap', 'true',
  #'--emitDecoratorMetadata', 'true',
  #'--experimentalDecorators', 'true',
  #'--removeComments', 'false'
  # '--strict', 'true',
  # '--strictNullChecks', 'true',
  # '--strictPropertyInitialization', 'true',
  # '--forceConsistentCasingInFileNames', 'true',
  # '--noFallthroughCasesInSwitch', 'true',
  # '--noImplicitAny', 'true',
  # '--noUnusedLocals', 'true',
  # '--noImplicitThis', 'true',
  # '--noImplicitReturns', 'true'
]
