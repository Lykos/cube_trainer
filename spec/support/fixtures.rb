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
  include_context 'with mode'

  let(:stat) do
    stat = Stat.find_or_initialize_by(mode: mode, stat_type: :averages)
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

shared_context 'with mode' do
  include_context 'with user abc'

  let(:mode) do
    mode = user.modes.find_or_initialize_by(
      name: 'test_mode'
    )
    mode.update(
      show_input_mode: :name,
      mode_type: :edge_commutators,
      buffer: TwistyPuzzles::Edge.for_face_symbols(%i[U F]),
      goal_badness: 1.0,
      cube_size: 3,
      known: false
    )
    mode.save!
    mode
  end
end

shared_context 'with color scheme' do
  include_context 'with user abc'

  let(:color_scheme) do
    color_scheme = ColorScheme.find_or_initialize_by(
      user: user
    )
    color_scheme.update(
      u: :yellow,
      f: :red,
      r: :green,
      l: :blue,
      b: :orange,
      d: :white
    )
    color_scheme.save!
    color_scheme
  end
end

shared_context 'with letter scheme' do
  include_context 'with user abc'

  let(:letter_scheme) do
    color_scheme = LetterScheme.find_or_initialize_by(
      user: user
    )
    part = TwistyPuzzles::Edge.for_face_symbols(%i[U F])
    color_scheme.mappings.new(part: part, letter: 'a')
    color_scheme.save!
    color_scheme
  end
end

shared_context 'with input' do
  include_context 'with mode'

  let(:input) do
    mode.inputs.find_or_create_by!(input_representation: CubeTrainer::LetterPair.new(%w[a b]))
  end
end

shared_context 'with result' do
  include_context 'with input'

  let(:result) do
    input.result&.destroy!
    partial_result = PartialResult.new(time_s: 10)
    result = Result.from_input_and_partial(input, partial_result)
    result.save!
    result
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
