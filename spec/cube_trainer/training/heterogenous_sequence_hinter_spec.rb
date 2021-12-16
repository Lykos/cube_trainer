# frozen_string_literal: true

require 'cube_trainer/training/alg_hinter'
require 'cube_trainer/training/case_solution'
require 'cube_trainer/alg_name'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/sequence_hinter'
require 'twisty_puzzles'
require 'rails_helper'

class FakeHeterogenousSequenceHinter < Training::HeterogenousSequenceHinter
  def generate_combinations(input)
    input.sub_names.map(&:sub_names)
  end
end

describe Training::HeterogenousSequenceHinter do
  include_context 'with mode'

  include TwistyPuzzles

  let(:cube_size) { 3 }
  let(:hinter_left) { Training::AlgHinter.new(algname_a => case_solution_a, algname_b => case_solution_b, algname_c => case_solution_c) }
  let(:hinter_right) { Training::AlgHinter.new(algname_d => case_solution_d) }
  let(:hinters) { [hinter_left, hinter_right] }
  let(:hinter) { FakeHeterogenousSequenceHinter.new(cube_size, [mode, mode], hinters) }
  let(:algname_a) { SimpleAlgName.new('a') }
  let(:algname_b) { SimpleAlgName.new('b') }
  let(:algname_c) { SimpleAlgName.new('c') }
  let(:algname_d) { SimpleAlgName.new('d') }
  let(:case_solution_a) { Training::CaseSolution.new(parse_algorithm("R'")) }
  let(:case_solution_b) { Training::CaseSolution.new(parse_algorithm('R')) }
  let(:case_solution_c) { Training::CaseSolution.new(parse_algorithm('U')) }
  let(:case_solution_d) { Training::CaseSolution.new(parse_algorithm('U2')) }

  before do
    Result.destroy_all
    5.times do |i|
      mode.results.create!(
        created_at: Time.zone.at(i), case_key: algname_a,
        time_s: 1.0, failed_attempts: 0, word: nil, success: true, num_hints: 0
      )
      mode.results.create!(
        created_at: Time.zone.at(i), case_key: algname_b,
        time_s: 2.0, failed_attempts: 0, word: nil, success: true, num_hints: 0
      )
      mode.results.create!(
        created_at: Time.zone.at(i), case_key: algname_d,
        time_s: 1.0, failed_attempts: 0, word: nil, success: true, num_hints: 0
      )
    end
  end

  it 'can give a prioritized list of hints' do
    input = CombinedAlgName.new(
      [
        CombinedAlgName.new([algname_a, algname_d]),
        CombinedAlgName.new([algname_b, algname_d]),
        CombinedAlgName.new([algname_c, algname_d])
      ]
    )
    hints = hinter.hints(input)
    expect(hints.length).to be == 2
    first_lines = hints[0].split("\n")
    expect(first_lines.length).to be == 3
    expect(first_lines[0]).to be == 'c, d: unknown (cancels 2)'
    expect(first_lines[1]).to be == 'a, d: 2.0'
    expect(first_lines[2]).to be == 'b, d: 3.0'
    second_lines = hints[1].split("\n")
    expect(second_lines.length).to be == 4
    expect(second_lines[0]).to be == "a: R'"
    expect(second_lines[1]).to be == 'b: R'
    expect(second_lines[2]).to be == 'c: U'
    expect(second_lines[3]).to be == 'd: U2'
  end
end
