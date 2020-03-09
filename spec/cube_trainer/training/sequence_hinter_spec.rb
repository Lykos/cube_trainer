# frozen_string_literal: true

require 'cube_trainer/training/alg_hinter'
require 'cube_trainer/alg_name'
require 'cube_trainer/core/parser'
require 'cube_trainer/training/input_item'
require 'cube_trainer/training/result'
require 'cube_trainer/training/sequence_hinter'

class FakeHeterogenousSequenceHinter < Training::HeterogenousSequenceHinter
  def generate_combinations(input)
    input.sub_names.map(&:sub_names)
  end
end

describe Training::HeterogenousSequenceHinter do
  include Core

  let(:cube_size) { 3 }
  let(:algname_a) { SimpleAlgName.new('a') }
  let(:algname_b) { SimpleAlgName.new('b') }
  let(:algname_c) { SimpleAlgName.new('c') }
  let(:algname_d) { SimpleAlgName.new('d') }
  let(:algorithm_a) { parse_algorithm("R'") }
  let(:algorithm_b) { parse_algorithm('R') }
  let(:algorithm_c) { parse_algorithm('U') }
  let(:algorithm_d) { parse_algorithm('U2') }
  let(:result_a) { Training::Result.new(:mode, Time.at(0), 1.0, algname_a, 0, nil) }
  let(:result_b) { Training::Result.new(:mode, Time.at(0), 2.0, algname_b, 0, nil) }
  let(:result_d) { Training::Result.new(:mode, Time.at(0), 1.0, algname_d, 0, nil) }
  let(:results_left) { [result_a, result_b] * 5 }
  let(:results_right) { [result_d] * 5 }
  let(:resultss) { [results_left, results_right] }
  let(:hinter_left) { Training::AlgHinter.new(algname_a => algorithm_a, algname_b => algorithm_b, algname_c => algorithm_c) }
  let(:hinter_right) { Training::AlgHinter.new(algname_d => algorithm_d) }
  let(:hinters) { [hinter_left, hinter_right] }
  let(:hinter) { FakeHeterogenousSequenceHinter.new(cube_size, resultss, hinters) }

  it 'can give a prioritized list of hints' do
    input = CombinedAlgName.new([
                                  CombinedAlgName.new([algname_a, algname_d]),
                                  CombinedAlgName.new([algname_b, algname_d]),
                                  CombinedAlgName.new([algname_c, algname_d])
                                ])
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
