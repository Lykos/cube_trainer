# frozen_string_literal: true

# Generator for a spec for a migration.
class MigrationSpecGenerator < Rails::Generators::NamedBase
  class_option :previous_version, type: :numeric, default: ActiveRecord::Migrator.current_version
  source_root File.expand_path('templates', __dir__)

  def create_spec_file
    raise unless file_name =~ /^\d+_[a-z0-9_]+/
    @file_name = file_name
    @previous_version = options[:previous_version]
    @current_version = current_version
    @class_name = spec_file_name_base.camelize
    raise if @current_version < @previous_version
    template('spec.rb.erb', "spec/migrations/#{spec_file_name_base}_spec.rb")
  end

  private

  def current_version
    file_name[/^\d+/].to_i
  end

  def spec_file_name_base
    "#{file_name.gsub(/^\d+_/, '')}"
  end
end
