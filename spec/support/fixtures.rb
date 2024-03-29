# frozen_string_literal: true

require 'twisty_puzzles'

shared_context 'with case set' do
  include_context 'with edges'

  let(:case_set) do
    CaseSets::BufferedThreeCycleSet.new(TwistyPuzzles::Edge, uf)
  end
end

shared_context 'with alg set' do
  include_context 'with edges'
  include_context 'with case set'
  include_context 'with alg spreadsheet'

  let(:alg_set) do
    alg_set = alg_spreadsheet.alg_sets.create!(case_set: case_set, sheet_title: 'test sheet')
    alg_set.algs.create!(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ur, ul])]
      ),
      alg: "M2 U M U2 M' U M2"
    )
    alg_set.algs.create!(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ur, lu])]
      ),
      alg: "[S', L F' L']"
    )
    alg_set.algs.create!(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ru, ul])]
      ),
      alg: "[R' F R, S]"
    )
    alg_set.algs.create!(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ru, lu])]
      ),
      alg: "M U' M' U2 M U' M'"
    )
    alg_set.algs.create!(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ul, ur])]
      ),
      alg: "M2 U' M U2 M' U' M2"
    )
    alg_set.algs.create!(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, ul, ru])]
      ),
      alg: "[S, R' F R]"
    )
    alg_set.algs.create!(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, lu, ur])]
      ),
      alg: "[L F' L', S']"
    )
    alg_set.algs.create!(
      casee: Case.new(
        part_cycles: [TwistyPuzzles::PartCycle.new([uf, lu, ru])]
      ),
      alg: "M U M' U2 M U M'"
    )
    alg_set.save!
    alg_set
  end
end

shared_context 'with user abc' do
  let(:user) do
    user = User.find_or_initialize_by(
      name: 'abc'
    )
    user.update(
      email: 'abc@example.org',
      provider: 'email',
      uid: 'abc@example.org',
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
    training_session.show_input_mode = :name
    training_session.training_session_type = :edge_commutators
    training_session.buffer = TwistyPuzzles::Edge.for_face_symbols(%i[U F])
    training_session.goal_badness = 1.0
    training_session.cube_size = 3
    training_session.known = false
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
  include_context 'with edges'

  let(:letter_scheme) do
    letter_scheme = LetterScheme.find_or_initialize_by(
      user: user
    )
    letter_scheme.wing_lettering_mode = :like_edges
    letter_scheme.xcenters_like_corners = true
    letter_scheme.tcenters_like_edges = true
    letter_scheme.midges_like_edges = true
    letter_scheme.save!
    letter_scheme.mappings.create!(part: uf, letter: 'A')
    letter_scheme.mappings.create!(part: ub, letter: 'D')
    letter_scheme.mappings.create!(part: df, letter: 'U')
    letter_scheme
  end
end

shared_context 'with edges' do
  let(:uf) { TwistyPuzzles::Edge.for_face_symbols(%i[U F]) }
  let(:fu) { TwistyPuzzles::Edge.for_face_symbols(%i[F U]) }
  let(:ur) { TwistyPuzzles::Edge.for_face_symbols(%i[U R]) }
  let(:ul) { TwistyPuzzles::Edge.for_face_symbols(%i[U L]) }
  let(:ub) { TwistyPuzzles::Edge.for_face_symbols(%i[U B]) }
  let(:lu) { TwistyPuzzles::Edge.for_face_symbols(%i[L U]) }
  let(:ru) { TwistyPuzzles::Edge.for_face_symbols(%i[R U]) }
  let(:df) { TwistyPuzzles::Edge.for_face_symbols(%i[D F]) }
end

shared_context 'with case' do
  include_context 'with edges'

  let(:casee) do
    casee = Case.new(part_cycles: [TwistyPuzzles::PartCycle.new([uf, df, ub])])
    casee.validate!
    casee
  end
end

shared_context 'with result' do
  include_context 'with training session'
  include_context 'with case'

  let(:result) do
    training_session.results.find_or_create_by!(
      casee: casee,
      time_s: 10
    )
  end
end

shared_context 'with alg override' do
  include_context 'with training session'
  include_context 'with case'

  let(:alg_override) do
    training_session.alg_overrides.find_or_create_by!(
      casee: casee,
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
