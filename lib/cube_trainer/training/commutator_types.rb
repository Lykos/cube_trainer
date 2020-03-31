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
    # TODO: Rename as it's not really only commutator types any more.
    module CommutatorTypes
      CommutatorInfo =
        Struct.new(
          :result_symbol,
          :generator_class,
          :learner_class,
          :default_cube_size,
          :has_buffer?
        )
      COMMUTATOR_TYPES = {
        memo_rush:
          CommutatorInfo.new(:memo_rush, CubeScrambles, MemoRusher, 3, false),
        corners:
          CommutatorInfo.new(:corner_commutators, CornerCommutators, HumanTimeLearner, 3, true),
        corner_parities:
          CommutatorInfo.new(:corner_parities_ul_ub, CornerParities, HumanTimeLearner, 3, true),
        corner_twists_plus_parities: CommutatorInfo.new(
          :corner_twists_plus_parities_ul_ub, CornerTwistsPlusParities,
          HumanTimeLearner, 3, true
        ),
        floating_2twists:
          CommutatorInfo.new(:floating_2twists, FloatingCorner2Twists, HumanTimeLearner, 3, true),
        corner_3twists:
          CommutatorInfo.new(:corner_3twists, Corner3Twists, HumanTimeLearner, 3, true),
        floating_2twists_and_corner_3twists: CommutatorInfo.new(
          :floating_2twists_and_corner_3twists, FloatingCorner2TwistsAnd3Twists,
          HumanTimeLearner, 3, true
        ),
        floating_2flips:
          CommutatorInfo.new(:floating_2flips, FloatingEdgeFlips, HumanTimeLearner, 3, false),
        edges: CommutatorInfo.new(:edge_commutators, EdgeCommutators, HumanTimeLearner, 3, true),
        wings: CommutatorInfo.new(:wing_commutators, WingCommutators, HumanTimeLearner, 4, true),
        xcenters:
          CommutatorInfo.new(:xcenter_commutators, XCenterCommutators, HumanTimeLearner, 4, true),
        tcenters:
          CommutatorInfo.new(:tcenter_commutators, TCenterCommutators, HumanTimeLearner, 5, true),
        words: CommutatorInfo.new(:letters_to_word, LettersToWord, HumanWordLearner, nil, false),
        oh_plls: CommutatorInfo.new(:oh_plls_by_name, Plls, HumanTimeLearner, 3, false),
        plls: CommutatorInfo.new(:plls_by_name, Plls, HumanTimeLearner, 3, false),
        oh_colls: CommutatorInfo.new(:oh_plls_by_name, Colls, HumanTimeLearner, 3, false),
        colls: CommutatorInfo.new(:plls_by_name, Colls, HumanTimeLearner, 3, false),
        olls_plus_cp: CommutatorInfo.new(:olls_plus_cp, OllsPlusCp, HumanTimeLearner, 3, false)
      }.freeze
    end
  end
end
