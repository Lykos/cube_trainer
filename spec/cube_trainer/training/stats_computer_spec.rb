# frozen_string_literal: true

require 'cube_trainer/training/stats_computer'
require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/input_item'
require 'ostruct'

describe Training::StatsComputer do
  let(:now) { Time.at(0) }
  let(:t_10_minutes_ago) { now - 600 }
  let(:t_2_hours_ago) { now - 2 * 3600 }
  let(:t_2_days_ago) { now - 2 * 24 * 3600 }
  let(:letter_scheme) { BernhardLetterScheme.new }
  let(:options) do
    options = OpenStruct.new
    options.cube_size = 3
    options.letter_scheme = letter_scheme
    options.commutator_info = Training::CommutatorOptions::COMMUTATOR_TYPES[:corners]
    options.new_item_boundary = 5
    options
  end
  let(:letter_pair_a) { LetterPair.new(%w[a a]) }
  let(:letter_pair_b) { LetterPair.new(%w[a b]) }
  let(:letter_pair_c) { LetterPair.new(%w[a c]) }
  let(:fill_letter_pairs) { ('a'..'z').map { |l| LetterPair.new(['b', l]) } }
  let(:mode) { BufferHelper.mode_for_options(options) }
  let(:results) do
    other_commutator_infos = Training::CommutatorOptions::COMMUTATOR_TYPES.reject { |k, _v| k == :corners }
    other_mode_results =
      other_commutator_infos.values.map.with_index do |v, i|
        patched_options = options.dup
        patched_options.commutator_info = v
        mode = BufferHelper.mode_for_options(patched_options)
        Training::Result.new(mode: mode, created_at: t_2_days_ago + 100 + i, time_s: 1.0, input_representation: letter_pair_b, failed_attempts: 0, word: nil, success: true, num_hints: 0)
      end
    fill_results = fill_letter_pairs.map.with_index { |ls, i| Training::Result.new(mode: mode, created_at: t_2_days_ago + 200 + i, time_s: 1.0, input_representation: ls, failed_attempts: 0, word: nil, success: true, num_hints: 0) }
    [
      Training::Result.new(mode: mode, created_at: t_10_minutes_ago, time_s: 1.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_10_minutes_ago + 1, time_s: 2.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_10_minutes_ago + 2, time_s: 3.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_10_minutes_ago + 3, time_s: 4.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_10_minutes_ago + 4, time_s: 5.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_10_minutes_ago - 1, time_s: 6.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_2_hours_ago, time_s: 7.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_2_days_ago, time_s: 10.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_2_days_ago + 1, time_s: 11.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_2_days_ago + 2, time_s: 12.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_2_days_ago + 3, time_s: 13.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_2_days_ago + 4, time_s: 14.0, input_representation: letter_pair_a, failed_attempts: 0, word: nil, success: true, num_hints: 0),
      Training::Result.new(mode: mode, created_at: t_2_hours_ago + 1, time_s: 10.0, input_representation: letter_pair_b, failed_attempts: 0, word: nil, success: true, num_hints: 0)
    ] + fill_results + other_mode_results
  end
  let(:computer) do
    Training::Result.delete_all
    results.each(&:save!)
    described_class.new(now, options)
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
    names = %i[corner_3twists corners edges floating_2flips floating_2twists]
    expect(stats.map { |s| s[:name] }.sort).to be == names
    expect(stats.map { |s| s[:weight] }.reduce(:+)).to be == 1.0
    stats.each do |s|
      expect(s[:expected_algs]).to be_a(Float)
      expect(s[:total_time]).to be_a(Float)
      expect(s[:weight]).to be_a(Float)
      if s[:name] == :corners
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
