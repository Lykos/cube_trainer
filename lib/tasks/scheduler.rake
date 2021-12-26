# frozen_string_literal: true

desc 'This task is called by the Heroku scheduler add-on and wraps the task scrape_sheets'
task scheduler_scrape_sheets: :scrape_sheets

