require 'capybara/rails'
require 'capybara_spa'
require 'selenium/webdriver'

# capybara.rb is responsible for configuring Capybara.
#
# It sets up two different JS drivers:
#
#   * :chrome
#   * :headless_chrome
#
# It hard codes an assumption that the Rails app runs on port 3001.
#
FrontendServer = CapybaraSpa::Server::NgStaticServer.new(
  build_path: File.dirname(__FILE__) + '/../../client/dist/cube-trainer',
  http_server_bin_path: File.dirname(__FILE__) + '/../../client/node_modules/.bin/angular-http-server',
  log_file: File.dirname(__FILE__) + '/../../log/angular-process.log',
  pid_file: File.dirname(__FILE__) + '/../../tmp/angular-process.pid'
)

RSpec.configure do |config|
  config.before(:each) do |example|
    if self.class.metadata[:type] == :system
      begin
        FrontendServer.start unless FrontendServer.started?
      rescue CapybaraSpa::Server::Error => ex
        # When an exception is raised it is being swallowed
        # so print it out and forcefully fail so the developer
        # see its.
        STDERR.puts ex.message, ex.backtrace.join("\n")
        exit!
      end
    end
  end
end

# This env var comes from the heroku-buildpack-google-chrome
chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)
# This env var comes from chromedriver_linux, e.g. TravisCI
chrome_bin ||= ENV.fetch('CHROME_BIN', nil)
chrome_options = {}
chrome_options[:binary] = chrome_bin if chrome_bin

 # Give us access to browser console logs, see spec/support/browser_logging.rb
logging_preferences = { browser: 'ALL' }

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: chrome_options,
    loggingPrefs: logging_preferences
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: chrome_options.merge(args: %w(headless disable-gpu)),
    loggingPrefs: logging_preferences
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.app_host = "http://localhost:#{FrontendServer.port}"
Capybara.always_include_port = true
Capybara.default_max_wait_time = 10
Capybara.javascript_driver = :chrome
Capybara.server = :puma
Capybara.server_port = 3001
