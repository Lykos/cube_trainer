SCHEDULE_FILE = "config/schedule.yml"

if Rails.env.production? && File.exist?(SCHEDULE_FILE) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash! YAML.load_file(SCHEDULE_FILE)
end
