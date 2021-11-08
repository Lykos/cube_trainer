# frozen_string_literal: true

shared_context 'with user abc' do
  let(:user) do
    user = User.find_or_initialize_by(
      name: 'abc'
    )
    user.update(
      email: 'abc@example.org',
      admin_confirmed: true,
      password: 'password',
      password_confirmation: 'password'
    )
    user.save!
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
      admin_confirmed: true,
      password: 'password',
      password_confirmation: 'password'
    )
    user.save!
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
      admin_confirmed: true,
      password: 'password',
      password_confirmation: 'password',
      admin: true
    )
    user.save!
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
      buffer: 'UF',
      goal_badness: 1.0,
      cube_size: 3,
      known: false
    )
    mode.save!
    mode
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
