# frozen_string_literal: true

require Rails.root.join('db/migrate/20200401001041_add_admin.rb')

describe AddAdmin, focus: true do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:schema_migration) { ActiveRecord::Base.connection.schema_migration }
  let(:migration_context) { ActiveRecord::MigrationContext.new(migrations_paths, schema_migration) }
  let(:previous_version) { 20200331235937 }
  let(:current_version) { 20200401001041 }
  subject { ActiveRecord::Migrator.new(action, migrations_paths, schema_migration, version_after_action) }

  around do |example|
    # Silence migrations output in specs report.
    ActiveRecord::Migration.suppress_messages do
      # Migrate to the version before the action runs.
      # Note that for down, this is actually the version _after_ the migration.
      migration_context.migrate(version_before_action)

      # If other tests using User table ran before this one, Rails has
      # stored information about table's columns and we need to reset those
      # since the migration changed the database structure.
      User.reset_column_information

      example.run

      # Migrate back to the newest version.
      migration_context.migrate

      # Re-update column information after the migration has been executed
      # again in the example. This will make user attributes cache
      # ready for other tests.
      User.reset_column_information
    end
  end

  describe :up do
    let(:action) { :up }
    let(:inverse_action) { :down }
    let(:version_before_action) { previous_version }
    let(:version_after_action) { current_version }

    it 'adds the system user to all existing results' do
      allow(OsHelper).to receive(:os_user).and_return('test_user')
      old_result = described_class::Result.new(time_s: 10)
      old_result.save!
      subject.run
      new_result = described_class::Result.find(old_result.id)
      expect(new_result.user.name).to eq('test_user')
    end

    it 'adds the system user with the default password' do
      allow(OsHelper).to receive(:os_user).and_return('test_user')
      allow(OsHelper).to receive(:default_password).and_return('test_user')
      subject.run
      user = User.find_first
      expect(user.name).to eq('test_user')
      expect(user.authenticate('test_password')).to be(true)
    end
  end

  describe :down do
    let(:action) { :down }
    let(:inverse_action) { :up }
    let(:version_before_action) { current_version }
    let(:version_after_action) { previous_version }

    it 'keeps all existing results' do
      old_result = described_class::Result.new(time_s: 10)
      old_result.save!
      subject.run
      new_result = described_class::Result.find(old_result.id)
      expect(new_result.time_s).to eq(10)
    end
  end
end
