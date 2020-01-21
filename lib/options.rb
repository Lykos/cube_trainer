require 'optparse'
require 'ostruct'
require 'commutator_sets'
require 'human_word_learner'
require 'human_time_learner'
require 'letters_to_word'
require 'letter_scheme';
require 'alg_sets'

module CubeTrainer

  class Options
    CommutatorInfo = Struct.new(:result_symbol, :generator_class, :learner_class, :default_cube_size, :has_buffer?)
    COMMUTATOR_TYPES = {
      'corners' => CommutatorInfo.new(:corner_commutators, CornerCommutators, HumanTimeLearner, 3, true),
      'corner_parities' => CommutatorInfo.new(:corner_parities_ul_ub, CornerParities, HumanTimeLearner, 3, true),
      'corner_twists_plus_parities' => CommutatorInfo.new(:corner_twists_plus_parities_ul_ub, CornerTwistsPlusParities, HumanTimeLearner, 3, true),
      'floating_2twists' => CommutatorInfo.new(:floating_2twists, FloatingCorner2Twists, HumanTimeLearner, 3, false),
      'corner_3twists' => CommutatorInfo.new(:corner_3twists, Corner3Twists, HumanTimeLearner, 3, false),
      'floating_2twists_and_corner_3twists' => CommutatorInfo.new(:floating_2twists_and_corner_3twists, FloatingCorner2TwistsAnd3Twists, HumanTimeLearner, 3, false),
      'floating_2flips' => CommutatorInfo.new(:floating_2flips, FloatingEdgeFlips, HumanTimeLearner, 3, false),
      'edges' => CommutatorInfo.new(:edge_commutators, EdgeCommutators, HumanTimeLearner, 3, true),
      'wings' => CommutatorInfo.new(:wing_commutators, WingCommutators, HumanTimeLearner, 4, true),
      'xcenters' => CommutatorInfo.new(:xcenter_commutators, XCenterCommutators, HumanTimeLearner, 4, true),
      'tcenters' => CommutatorInfo.new(:tcenter_commutators, TCenterCommutators, HumanTimeLearner, 5, true),
      'words' => CommutatorInfo.new(:letters_to_word, LettersToWord, HumanWordLearner, nil, false),
      'oh_plls' => CommutatorInfo.new(:oh_plls_by_name, Plls, HumanTimeLearner, 3, false),
      'plls' => CommutatorInfo.new(:plls_by_name, Plls, HumanTimeLearner, 3, false),
      'oh_colls' => CommutatorInfo.new(:oh_plls_by_name, Colls, HumanTimeLearner, 3, false),
      'colls' => CommutatorInfo.new(:plls_by_name, Colls, HumanTimeLearner, 3, false),
    }
    
    def self.parse(args)
      options = OpenStruct.new
      # Default options
      options.new_item_boundary = 11
      options.commutator_info = COMMUTATOR_TYPES['corners']
      options.restrict_letters = nil
      options.exclude_letters = []
      options.letter_scheme = BernhardLetterScheme.new
      options.color_scheme = ColorScheme::BERNHARD
      options.restrict_colors = options.color_scheme.colors
      options.picture = false
      options.mute = false
      options.buffer = nil
      opt_parser = OptionParser.new do |opts|
        opts.separator ''
        opts.separator 'Specific options:'      
        opts.on('-c', '--commutator_type TYPE', COMMUTATOR_TYPES, 'Use the given type of commutators for training.') do |info|
          options.commutator_info = info
          if options.cube_size.nil? and not info.default_cube_size.nil? then options.cube_size = info.default_cube_size end
        end

        opts.on('-t', '--[no-]test_comms', 'Test commutators at startup.') do |test|
          options.test_comms = test
        end

        opts.on('-b', '--buffer BUFFER', /\w+/, 'Buffer to use instead of the default one.') do |b|
          options.buffer = b
        end

        opts.on('-x', '--restrict_colors COLORLIST', /[yrbgow]+/, 'Restrict colors to find a layer for.') do |colors|
          options.restrict_colors = colors.each_char.collect { |c| options.color_scheme.colors.find { |o| o.to_s[0] == c } }
        end

        opts.on('-s', '--size SIZE', Integer, 'Use the given cube size.') do |size|
          options.cube_size = size
        end

        opts.on('-p', '--[no-]picture', 'Show a picture of the cube instead of the letter pair.') do |p|
          options.picture = p
        end
  
        opts.on('-n', '--new_item_boundary INTEGER', Integer, 'Number of repetitions at which we stop considering an item a "new item" that needs to be repeated occasionally.') do |int|
          options.new_item_boundary = int
        end
  
        opts.on('-v', '--[no-]verbose', 'Give more verbose information.') do |v|
          options.verbose = v
        end

        opts.on('-m', '--[no-]mute', 'Mute (i.e. no audio).') do |m|
          options.mute = m
        end
  
        opts.on('-r', '--restrict_letters LETTERLIST', /\w+/, 'List of letters to which the commutators should be restricted.',
                '  (Only uses commutators that contain at least one of the given letters)') do |letters|
          options.restrict_letters = letters.downcase.split('')
        end

        opts.on('-e', '--exclude_letters LETTERLIST', /\w+/,  'List of letters which should be excluded for commutators.',
                '  (Only uses commutators that contain none of the given letters)') do |letters|
          options.exclude_letters = letters.downcase.split('')
        end
        
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end   
      end
      opt_parser.parse!(args)
      raise "Option --commutator_type is required." unless options.commutator_info
      options
    end
  end

end
