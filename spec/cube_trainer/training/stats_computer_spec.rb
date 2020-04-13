# frozen_string_literal: true

require 'cube_trainer/training/stats_computer'
require 'cube_trainer/training/input_item'
require 'fixtures'
require 'ostruct'

def construct_mode(mode_type)
  mode = user.modes.find_or_initialize_by(
    name: mode_type.to_s,
  )
  mode.update(
    show_input_mode: :name,
    mode_type: mode_type,
    goal_badness: 1.0,
    cube_size: 3,
    known: false
  )
  mode.save!
  mode
end

xdescribe Training::StatsComputer do
  include_context :user

  let(:now) { Time.at(0) }
  let(:t_10_minutes_ago) { now - 600 }
  let(:t_2_hours_ago) { now - 2 * 3600 }
  let(:t_2_days_ago) { now - 2 * 24 * 3600 }
  let(:mode) { construct_mode(:corner_commutators) }
  let(:letter_pair_a) { LetterPair.new(%w(a a)) }
  let(:letter_pair_b) { LetterPair.new(%w(a b)) }
  let(:letter_pair_c) { LetterPair.new(%w(a c)) }
  let(:fill_letter_pairs) { ('a'..'z').map { |l| LetterPair.new(['b', l]) } }
  let(:results) do
    Result.delete_all
    other_modes = Mode::MODE_TYPE_NAMES.reject { |k| k == :corner_commutators }.map { |k| construct_mode(k) }
    other_mode_results = other_modes.map.with_index do |mode, i|
        Result.create!(
          input: mode.inputs.create!(created_at: t_2_days_ago + 100 + i, input_representation: letter_pair_b),
          time_s: 1.0, failed_attempts: 0, word: nil, success: true, num_hints: 0
        )
      end
    fill_results = fill_letter_pairs.map.with_index { |ls, i| Result.create!(input: mode.inputs.create!(created_at: t_2_days_ago + 200 + i, input_representation: ls), time_s: 1.0, failed_attempts: 0, word: nil, success: true, num_hints: 0) }
    [
      Result.create!(input: mode.inputs.create!(created_at: t_10_minutes_ago, input_representation: letter_pair_a), time_s: 1.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_10_minutes_ago + 1, input_representation: letter_pair_a), time_s: 2.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_10_minutes_ago + 2, input_representation: letter_pair_a), time_s: 3.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_10_minutes_ago + 3, input_representation: letter_pair_a), time_s: 4.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_10_minutes_ago + 4, input_representation: letter_pair_a), time_s: 5.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_10_minutes_ago - 1, input_representation: letter_pair_a), time_s: 6.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_2_hours_ago, input_representation: letter_pair_a), time_s: 7.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_2_days_ago, input_representation: letter_pair_a), time_s: 10.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_2_days_ago + 1, input_representation: letter_pair_a), time_s: 11.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_2_days_ago + 2, input_representation: letter_pair_a), time_s: 12.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_2_days_ago + 3, input_representation: letter_pair_a), time_s: 13.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_2_days_ago + 4, input_representation: letter_pair_a), time_s: 14.0, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Result.create!(input: mode.inputs.create!(created_at: t_2_hours_ago + 1, input_representation: letter_pair_b), time_s: 10.0, failed_attempts: 0, word: nil, success: true, num_hints: 0)
    ] + fill_results + other_mode_results
  end
  let(:computer) do
    described_class.new(now, mode)
  end

  it 'computes detailed averages for all our results' do
    fill_letter_averages = fill_letter_pairs.map { |ls| [ls, 1.0] }
    expected = [[letter_pair_b, 10.0], [letter_pair_a, 3.0]] + fill_letter_averages
    expect(computer.averages).to be == expected
  end

  it 'computes which are our bad results' do
    expected_bad_results = [[1.0, 2], [1.1, 2], [1.2, 2], [1.3, 2], [1.4, 2], [1.5, 2]]
    expect(computer.bad_results).to be == expected_bad_results
  end

  it 'computes how many results we had now and 24 hours ago' do
    expect(computer.total_average).to be == (26 * 1.0 + 10.0 + 3.0) / 28
    expect(computer.old_total_average).to be == (26 * 1.0 + 12.0) / 27
  end

  it 'computes how long each part of the solve takes' do
    stats = computer.expected_time_per_type_stats
    names = %i[corner_3twists corner_commutators edge_commutators floating_2flips floating_2twists]
    expect(stats.map { |s| s[:name] }.sort).to be == names
    expect(stats.map { |s| s[:weight] }.reduce(:+)).to be == 1.0
    stats.each do |s|
      expect(s[:expected_algs]).to be_a(Float)
      expect(s[:total_time]).to be_a(Float)
      expect(s[:weight]).to be_a(Float)
      if s[:name] == :corner_commutators
        expect(s[:average]).to be == (26 * 1.0 + 10.0 + 3.0) / 28
      else
        expect(s[:average]).to be == 1.0
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
