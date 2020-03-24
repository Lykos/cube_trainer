# frozen_string_literal: true

require 'cube_trainer/training/stats_computer'
require 'cube_trainer/training/legacy_result'
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
      other_commutator_infos.map do |_k, v|
        patched_options = options.dup
        patched_options.commutator_info = v
        mode = BufferHelper.mode_for_options(patched_options)
        Training::LegacyResult.new(mode, t_2_days_ago, 1.0, letter_pair_b, 0, nil, true, 0)
      end
    fill_results = fill_letter_pairs.map { |ls| Training::LegacyResult.new(mode, t_2_days_ago, 1.0, ls, 0, nil, true, 0) }
    [
      Training::LegacyResult.new(mode, t_10_minutes_ago, 1.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_10_minutes_ago, 2.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_10_minutes_ago, 3.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_10_minutes_ago, 4.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_10_minutes_ago, 5.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_10_minutes_ago - 1, 6.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_2_hours_ago, 7.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_2_days_ago, 10.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_2_days_ago, 11.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_2_days_ago, 12.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_2_days_ago, 13.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_2_days_ago, 14.0, letter_pair_a, 0, nil, true, 0),
      Training::LegacyResult.new(mode, t_2_hours_ago, 10.0, letter_pair_b, 0, nil, true, 0)
    ] + fill_results + other_mode_results
  end
  let(:results_persistence) do
    persistence = Training::ResultsPersistence.create_in_memory
    results.each { |r| persistence.record_result(r) }
    persistence
  end
  let(:computer) { described_class.new(now, options, results_persistence) }

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
