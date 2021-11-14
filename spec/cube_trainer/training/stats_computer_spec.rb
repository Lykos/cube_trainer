# frozen_string_literal: true

require 'cube_trainer/training/stats_computer'
require 'cube_trainer/training/input_item'
require 'cube_trainer/letter_pair'
require 'pry'
require 'ostruct'

def construct_mode(mode_type)
  mode = user.modes.find_or_initialize_by(
    name: mode_type.to_s
  )
  buffer = mode_type.has_buffer? ? mode_type.part_type::ELEMENTS.first : nil
  mode.update(
    show_input_mode: :name,
    mode_type: mode_type,
    goal_badness: 1.0,
    cube_size: mode_type.default_cube_size,
    known: false,
    buffer: buffer
  )
  mode.save!
  mode
end

xdescribe Training::StatsComputer do
  include_context 'with user abc'

  let(:now) { Time.zone.at(0) }
  let(:t_10_minutes_ago) { now - 600 }
  let(:t_2_hours_ago) { now - (2 * 3600) }
  let(:t_2_days_ago) { now - (2 * 24 * 3600) }
  let(:mode) { construct_mode(ModeType.find_by!(key: :corner_commutators)) }
  let(:letter_pair_a) { LetterPair.new(%w[a a]) }
  let(:letter_pair_b) { LetterPair.new(%w[a b]) }
  let(:letter_pair_c) { LetterPair.new(%w[a c]) }
  let(:fill_letter_pairs) { ('a'..'z').map { |l| LetterPair.new(['b', l]) } }
  let(:other_mode_types) { ModeType.all.reject { |k| k.key == :corner_commutators || !k.has_bounded_inputs? || k.has_parity_parts? } }
  let(:other_modes) { other_mode_types.map { |k| construct_mode(k) } }
  let(:other_mode_results) do
    other_modes.map.with_index do |mode, i|
      Result.create!(
        input: mode.inputs.create!(created_at: t_2_days_ago + 100 + i, input_representation: letter_pair_b),
        time_s: 1.0, failed_attempts: 0, word: nil, success: true, num_hints: 0
      )
    end
  end
  let(:fill_results) do
    fill_letter_pairs.map.with_index { |ls, i| Result.create!(input: mode.inputs.create!(created_at: t_2_days_ago + 200 + i, input_representation: ls), time_s: 1.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_2_days_ago + 201 + i) }
  end
  let(:relevant_results) do
    [
      Result.create!(
        input: mode.inputs.create!(created_at: t_10_minutes_ago, input_representation: letter_pair_a),
        time_s: 1.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_10_minutes_ago + 1
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_10_minutes_ago + 2, input_representation: letter_pair_a),
        time_s: 2.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_10_minutes_ago + 3
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_10_minutes_ago + 4, input_representation: letter_pair_a),
        time_s: 3.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_10_minutes_ago + 5
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_10_minutes_ago + 6, input_representation: letter_pair_a),
        time_s: 4.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_10_minutes_ago + 7
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_10_minutes_ago + 8, input_representation: letter_pair_a),
        time_s: 5.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_10_minutes_ago + 9
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_10_minutes_ago - 2, input_representation: letter_pair_a),
        time_s: 6.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_10_minutes_ago - 1
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_2_hours_ago, input_representation: letter_pair_a),
        time_s: 7.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_2_hours_ago + 1
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_2_days_ago, input_representation: letter_pair_a),
        time_s: 10.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_2_days_ago + 1
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_2_days_ago + 2, input_representation: letter_pair_a),
        time_s: 11.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_2_days_ago + 3
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_2_days_ago + 4, input_representation: letter_pair_a),
        time_s: 12.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_2_days_ago + 5
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_2_days_ago + 6, input_representation: letter_pair_a),
        time_s: 13.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_2_days_ago + 7
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_2_days_ago + 8, input_representation: letter_pair_a),
        time_s: 14.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_2_days_ago + 9
      ),
      Result.create!(
        input: mode.inputs.create!(created_at: t_2_hours_ago + 2, input_representation: letter_pair_b),
        time_s: 10.0, failed_attempts: 0, word: nil, success: true, num_hints: 0, created_at: t_2_hours_ago + 3
      )
    ]
  end
  let(:results) do
    Result.destroy_all
    relevant_results + fill_results + other_mode_results
  end
  let(:computer) do
    results
    described_class.new(now, mode)
  end

  xit 'computes detailed averages for all our results' do
    fill_letter_averages = fill_letter_pairs.map { |ls| [ls, 1.0] }
    expected = [[letter_pair_b, 10.0], [letter_pair_a, 3.0]] + fill_letter_averages
    expect(computer.averages).to be == expected
  end

  it 'computes which are our bad results' do
    expected_bad_results = [[1.0, 2], [1.1, 2], [1.2, 2], [1.3, 2], [1.4, 2], [1.5, 2]]
    expect(computer.bad_results).to be == expected_bad_results
  end

  it 'computes how many results we had now and 24 hours ago' do
    expect(computer.total_average).to be_within(0.1).of(((26 * 1.0) + 10.0 + 3.0) / 28)
    expect(computer.old_total_average).to be_within(0.1).of(((26 * 1.0) + 12.0) / 27)
  end

  xit 'computes how long each part of the solve takes' do
    stats = computer.expected_time_per_type_stats
    names = %i[corner_3twists corner_commutators edge_commutators floating_2flips floating_2twists]
    expect(stats.pluck(:name).sort).to be == names
    expect(stats.pluck(:weight).sum).to be_within(0.1).of(1.0)
    stats.each do |s|
      expect(s[:expected_algs]).to be_a(Float)
      expect(s[:total_time]).to be_a(Float)
      expect(s[:weight]).to be_a(Float)
      if s[:name] == :corner_commutators
        expect(s[:average]).to be_within(0.1).of(((26 * 1.0) + 10.0 + 3.0) / 28)
      else
        expect(s[:average]).to be_within(0.1).of(1.0)
      end
    end
  end

  it 'computes how many items we have already seen and how many are new' do
    inputs = [letter_pair_a, letter_pair_b, letter_pair_c].map { |ls| Training::InputItem.new(ls) }
    stats = computer.input_stats(inputs)
    expect(stats[:found]).to be == 2
    expect(stats[:total]).to be == 3
    expect(stats[:newish_elements]).to be == 1
    expect(stats[:missing]).to be == 1
    expect(computer.num_results).to be == 13 + 26
    expect(computer.num_recent_results).to be == 8
  end
end
