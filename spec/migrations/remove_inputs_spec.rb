# frozen_string_literal: true

require Rails.root.join('db/migrate/20211215010803_remove_inputs.rb')

describe RemoveInputs do
  include_context 'with mode'
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:schema_migration) { ActiveRecord::Base.connection.schema_migration }
  let(:migration_context) { ActiveRecord::MigrationContext.new(migrations_paths, schema_migration) }
  let(:migrations) { migration_context.migrations }
  let(:previous_version) { 20211201001114 }
  let(:current_version) { 20211215010803 }
  subject { ActiveRecord::Migrator.new(action, migrations, schema_migration, version_after_action) }
  let(:migrated_models) { [RemoveInputs::Input, RemoveInputs::Result] }

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
    let(:input) { Input.create!(mode_id: mode.id, input_representation: 'Scramble:R') }
    let(:result) { Result.create!(input_id: input.id, time_s: 12.2) }
    
    it 'should move the data from the input to the result' do
      result

      subject

      expect(result.mode_id).to eq(mode.id)
      expect(result.representation).to eq('Scramble:R')
    end
  end

  describe :down do
    let(:action) { :down }
    let(:inverse_action) { :up }
    let(:version_before_action) { current_version }
    let(:version_after_action) { previous_version }
    let(:result) { Result.create!(representation: 'Scramble:R', mode_id: mode.id, time_s: 12.2) }

    it 'should move the data from the result to the input' do
      result

      subject

      input = Input.find_by(id: result.input_id)
      expect(input.input_representation).to eq('Scramble:R')
      expect(input.mode_id).to eq(mode.id)
    end
  end
end
