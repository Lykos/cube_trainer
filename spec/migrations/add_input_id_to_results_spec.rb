# frozen_string_literal: true

require Rails.root.join('db/migrate/20200401075549_add_input_id_to_results.rb')

describe AddInputIdToResults do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:schema_migration) { ActiveRecord::Base.connection.schema_migration }
  let(:migration_context) { ActiveRecord::MigrationContext.new(migrations_paths, schema_migration) }
  let(:migrations) { migration_context.migrations }
  let(:previous_version) { 20200401001952 }
  let(:current_version) { 20200401075549 }
  subject { ActiveRecord::Migrator.new(action, migrations, schema_migration, version_after_action) }
  let(:migrated_models) { raise NotImplementedError, 'Specify a list of models that are updated in the migration.' }

  around do |example|
    # Silence migrations output in specs report.
    ActiveRecord::Migration.suppress_messages do
      # Migrate to the version before the action runs.
      # Note that for down, this is actually the version _after_ the migration.
      migration_context.migrate(version_before_action)

      # If other tests using the models ran before this one, Rails has
      # stored information about table's columns and we need to reset those
      # since the migration changed the database structure.
      migrated_models.each(&:reset_column_information)

      example.run

      # Re-update column information after the migration has been executed
      # again in the example. This will make user attributes cache
      # ready for other tests.
      migrated_models.each(&:reset_column_information)
    end
  end

  describe :up do
    let(:action) { :up }
    let(:inverse_action) { :down }
    let(:version_before_action) { previous_version }
    let(:version_after_action) { current_version }

    pending 'describe up'
  end

  describe :down do
    let(:action) { :down }
    let(:inverse_action) { :up }
    let(:version_before_action) { current_version }
    let(:version_after_action) { previous_version }

    pending 'describe down'
  end
end
