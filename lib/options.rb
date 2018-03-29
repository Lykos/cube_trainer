require 'optparse'
require 'ostruct'
require 'commutators'
require 'human_word_learner'
require 'human_time_learner'
require 'letters_to_word'
require 'alg_sets'

module CubeTrainer

  class Options
    CommutatorInfo = Struct.new(:result_symbol, :generator_class, :learner_class, :default_cube_size)
    COMMUTATOR_TYPES = {
      'corners' => CommutatorInfo.new(:corner_commutators, CornerCommutators, HumanTimeLearner, 3),
      'edges' => CommutatorInfo.new(:edge_commutators, EdgeCommutators, HumanTimeLearner, 3),
      'wings' => CommutatorInfo.new(:wing_commutators, WingCommutators, HumanTimeLearner, 4),
      'xcenters' => CommutatorInfo.new(:xcenter_commutators, XCenterCommutators, HumanTimeLearner, 4),
      'tcenters' => CommutatorInfo.new(:tcenter_commutators, TCenterCommutators, HumanTimeLearner, 5),
      'words' => CommutatorInfo.new(:letters_to_word, LettersToWord, HumanWordLearner, nil),
      'oh_plls' => CommutatorInfo.new(:oh_plls_by_name, PllsByName, HumanTimeLearner, 3),
      'plls' => CommutatorInfo.new(:plls_by_name, PllsByName, HumanTimeLearner, 3)
    }
    
    def self.parse(args)
      options = OpenStruct.new
      # Default options
      options.new_item_boundary = 11
      options.restrict_colors = COLORS
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

        opts.on('-x', '--restrict_colors COLORLIST', /[yrbgow]+/, 'Restrict colors to find a layer for.') do |colors|
          options.restrict_colors = colors.each_char.collect { |c| COLORS.find { |o| o.to_s[0] == c } }
        end

        opts.on('-s', '--size SIZE', Integer, 'Use the given cube size.') do |size|
          options.cube_size = size
        end
  
        opts.on('-n', '--new_item_boundary INTEGER', Integer, 'Number of repetitions at which we stop considering an item a "new item" that needs to be repeated occasionally.') do |int|
          options.new_item_boundary = int
        end
  
        opts.on('-v', '--[no-]verbose', 'Give more verbose information.') do |v|
          options.verbose = v
        end
  
        opts.on('-r', '--restrict_letters LETTERLIST', /[a-xA-x]+/, 'List of letters to which the commutators should be restricted.',
                '  (Only uses commutators that contain at least one of the given letters)') do |letters|
          options.restrict_letters = letters.downcase.split('')
        end
        
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end   
      end
      opt_parser.parse!(args)
      options
    end
  end

end
