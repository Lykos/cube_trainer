# frozen_string_literal: true

require 'cube_trainer/utils/array_helper'

# Generator for a spec for a migration.
class MigrationSpecGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_spec_file
    @previous_version = previous_version
    @current_version = current_migration.version
    raise if @current_version < @previous_version
    @migration_file_name = current_migration.filename
    template('spec.rb.erb', "spec/migrations/#{file_name}_spec.rb")
  end

  private

  include CubeTrainer::Utils::ArrayHelper

  def migrations
    migrations_paths = ActiveRecord::Migrator.migrations_paths
    schema_migration = ActiveRecord::Base.connection.schema_migration
    migration_context = ActiveRecord::MigrationContext.new(migrations_paths, schema_migration)
    @migrations ||= migration_context.migrations
  end

  def current_migration
    @current_migration ||= find_only(migrations) { |m| m.name == class_name }
  end

  def previous_version
    @previous_version ||=
      begin
        current_index = migrations.index(current_migration)
        migrations[current_index - 1].version
      end
  end
end
