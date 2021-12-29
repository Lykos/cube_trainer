# frozen_string_literal: true

require 'twisty_puzzles'

shared_context 'with user abc' do
  let(:user) do
    user = User.find_or_initialize_by(
      name: 'abc'
    )
    user.update(
      email: 'abc@example.org',
      provider: 'email',
      uid: 'abc@example.org',
      admin_confirmed: true,
      email_confirmed: true,
      password: 'password',
      password_confirmation: 'password'
    )
    user.save!
    user.confirm
    user
  end
end

shared_context 'with user eve' do
  let(:eve) do
    user = User.find_or_initialize_by(
      name: 'eve'
    )
    user.update(
      email: 'eve@example.org',
      provider: 'email',
      uid: 'eve@example.org',
      admin_confirmed: true,
      email_confirmed: true,
      password: 'password',
      password_confirmation: 'password'
    )
    user.save!
    user.confirm
    user
  end
end

shared_context 'with user admin' do
  let(:admin) do
    user = User.find_or_initialize_by(
      name: 'admin'
    )
    user.update(
      email: 'admin@example.org',
      provider: 'email',
      uid: 'admin@example.org',
      admin_confirmed: true,
      email_confirmed: true,
      password: 'password',
      password_confirmation: 'password',
      admin: true
    )
    user.save!
    user.confirm
    user
  end
end

shared_context 'with achievement grant' do
  include_context 'with user abc'

  let(:achievement_grant) do
    AchievementGrant.find_or_create_by!(user: user, achievement: :fake)
  end
end

shared_context 'with stat' do
  include_context 'with training session'

  let(:stat) do
    stat = Stat.find_or_initialize_by(training_session: training_session, stat_type: :averages)
    stat.update(index: 0)
    stat.save!
    stat
  end
end

shared_context 'with message' do
  include_context 'with user abc'

  let(:user_message) do
    message = Message.find_or_initialize_by(user: user, title: 'message_title')
    message.update(body: 'message_body', read: false)
    message.save!
    message
  end
end

shared_context 'with training session' do
  include_context 'with user abc'

  let(:training_session) do
    training_session = user.training_sessions.find_or_initialize_by(
      name: 'test_training_session'
    )
    training_session.update(
      show_input_mode: :name,
      training_session_type: :edge_commutators,
      buffer: TwistyPuzzles::Edge.for_face_symbols(%i[U F]),
      goal_badness: 1.0,
      cube_size: 3,
      known: false
    )
    training_session.save!
    training_session
  end
end

shared_context 'with color scheme' do
  include_context 'with user abc'

  let(:color_scheme) do
    color_scheme = ColorScheme.find_or_initialize_by(
      user: user
    )
    color_scheme.update(
      color_u: :yellow,
      color_f: :red
    )
    color_scheme.save!
    color_scheme
  end
end

shared_context 'with letter scheme' do
  include_context 'with user abc'

  let(:letter_scheme) do
    letter_scheme = LetterScheme.find_or_initialize_by(
      user: user
    )
    part = TwistyPuzzles::Edge.for_face_symbols(%i[U F])
    letter_scheme.mappings.new(part: part, letter: 'a')
    letter_scheme.save!
    letter_scheme
  end
end

shared_context 'with result' do
  include_context 'with training session'

  let(:result) do
    training_session.results.find_or_create_by!(case_key: CubeTrainer::LetterPair.new(%w[a b]), time_s: 10)
  end
end

shared_context 'with alg override' do
  include_context 'with training session'

  let(:alg_override) do
    uf = TwistyPuzzles::Edge.for_face_symbols(%i[U F])
    df = TwistyPuzzles::Edge.for_face_symbols(%i[D F])
    ub = TwistyPuzzles::Edge.for_face_symbols(%i[U B])
    training_session.alg_overrides.find_or_create_by!(
      case_key: TwistyPuzzles::PartCycle.new([uf, df, ub]),
      alg: "[M', U2]"
    )
  end
end

shared_context 'with headers' do
  let(:headers) { { ACCEPT: 'application/json' } }
end

shared_context 'with user auth headers' do
  include_context 'with headers'
  include_context 'with user abc'

  let(:user_headers) do
    user.create_new_auth_token.merge!(headers)
  end
end

shared_context 'with eve auth headers' do
  include_context 'with headers'
  include_context 'with user eve'

  let(:eve_headers) do
    eve.create_new_auth_token.merge!(headers)
  end
end

shared_context 'with alg spreadsheet' do
  let(:alg_spreadsheet) do
    AlgSpreadsheet.create!(
      owner: 'Testy Testikow',
      spreadsheet_id: '1l3IcCG0vVJbZtj30ZXQTn1UBWTya6i84tUZZg5PN3OY'
    )
  end
end
