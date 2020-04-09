# frozen_string_literal: true

require 'cube_trainer/training/commutator_hint_parser'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/cube_scrambles'
require 'cube_trainer/training/human_word_learner'
require 'cube_trainer/training/human_time_learner'
require 'cube_trainer/training/letters_to_word'
require 'cube_trainer/training/alg_sets'
require 'cube_trainer/training/memo_rusher'

module CubeTrainer
  module Training
    # Informations about all available commutator types.
    # TODO: Rename and move to Mode::MODE_TYPE it's not really only commutator types any more.
    module CommutatorTypes
      SHOW_INPUT_MODES = %i(picture name)

      CommutatorInfo =
        Struct.new(
          :result_symbol,
          :generator_class,
          :learner_class,
          :default_cube_size,
          :has_buffer?,
          :has_goal_badness?,
          :show_input_modes
        ) do
        # Returns a simple version that can be returned to the frontend.
        def to_simple
          {
            name: result_symbol,
            default_cube_size: default_cube_size,
            has_buffer: has_buffer?,
            has_goal_badness: has_goal_badness?,
            show_input_modes: show_input_modes
          }
        end

        alias name result_symbol
      end

      COMMUTATOR_TYPES = {
        memo_rush:
          CommutatorInfo.new(:memo_rush, CubeScrambles, MemoRusher, 3, false, false, SHOW_INPUT_MODES),
        corners:
          CommutatorInfo.new(:corner_commutators, CornerCommutators, HumanTimeLearner, 3, true, true, SHOW_INPUT_MODES),
        corner_parities:
          CommutatorInfo.new(:corner_parities_ul_ub, CornerParities, HumanTimeLearner, 3, true, true, SHOW_INPUT_MODES),
        corner_twists_plus_parities: CommutatorInfo.new(
          :corner_twists_plus_parities_ul_ub, CornerTwistsPlusParities,
          HumanTimeLearner, 3, true, SHOW_INPUT_MODES),
        floating_2twists:
          CommutatorInfo.new(:floating_2twists, FloatingCorner2Twists, HumanTimeLearner, 3, true, true, SHOW_INPUT_MODES),
        corner_3twists:
          CommutatorInfo.new(:corner_3twists, Corner3Twists, HumanTimeLearner, 3, true, true, SHOW_INPUT_MODES),
        floating_2twists_and_corner_3twists: CommutatorInfo.new(
          :floating_2twists_and_corner_3twists, FloatingCorner2TwistsAnd3Twists,
          HumanTimeLearner, 3, true, SHOW_INPUT_MODES),
        floating_2flips:
          CommutatorInfo.new(:floating_2flips, FloatingEdgeFlips, HumanTimeLearner, 3, false, SHOW_INPUT_MODES),
        edges: CommutatorInfo.new(:edge_commutators, EdgeCommutators, HumanTimeLearner, 3, true, true, SHOW_INPUT_MODES),
        wings: CommutatorInfo.new(:wing_commutators, WingCommutators, HumanTimeLearner, 4, true, true, SHOW_INPUT_MODES),
        xcenters:
          CommutatorInfo.new(:xcenter_commutators, XCenterCommutators, HumanTimeLearner, 4, true, true, SHOW_INPUT_MODES),
        tcenters:
          CommutatorInfo.new(:tcenter_commutators, TCenterCommutators, HumanTimeLearner, 5, true, true, SHOW_INPUT_MODES),
        words: CommutatorInfo.new(:letters_to_word, LettersToWord, HumanWordLearner, nil, false, true, SHOW_INPUT_MODES),
        oh_plls: CommutatorInfo.new(:oh_plls_by_name, Plls, HumanTimeLearner, 3, false, true, SHOW_INPUT_MODES),
        plls: CommutatorInfo.new(:plls_by_name, Plls, HumanTimeLearner, 3, false, true, SHOW_INPUT_MODES),
        oh_colls: CommutatorInfo.new(:oh_colls_by_name, Colls, HumanTimeLearner, 3, false, true, SHOW_INPUT_MODES),
        colls: CommutatorInfo.new(:colls_by_name, Colls, HumanTimeLearner, 3, false, true, SHOW_INPUT_MODES),
        olls_plus_cp: CommutatorInfo.new(:olls_plus_cp, OllsPlusCp, HumanTimeLearner, 3, false, true, SHOW_INPUT_MODES)
      }.freeze
    end
  end
end
