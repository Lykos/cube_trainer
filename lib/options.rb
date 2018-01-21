require 'optparse'
require 'ostruct'
require 'commutators'
  
module CubeTrainer

  class Options
    CommutatorInfo = Struct.new(:result_symbol, :generator_class, :default_cube_size)
    COMMUTATOR_TYPES = {
      'corners' => CommutatorInfo.new(:corner_commutators, CornerCommutators, 3),
      'edges' => CommutatorInfo.new(:edge_commutators, EdgeCommutators, 3),
      'wings' => CommutatorInfo.new(:wing_commutators, WingCommutators, 4),
      'xcenters' => CommutatorInfo.new(:xcenter_commutators, XCenterCommutators, 4),
      'tcenters' => CommutatorInfo.new(:tcenter_commutators, TCenterCommutators, 5)
    }
    
    def self.parse(args)
      options = OpenStruct.new
      options.new_item_boundary = 11
      opt_parser = OptionParser.new do |opts|
        opts.separator ''
        opts.separator 'Specific options:'      
        opts.on('-c', '--commutator_type TYPE', COMMUTATOR_TYPES, 'Use the given type of commutators for training.') do |info|
          options.commutator_info = info
          if options.cube_size.nil? then options.cube_size = info.default_cube_size end
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
  
        opts.on('-r', '--restrict LETTERLIST', /[a-xA-x]+/, 'List of letters to which the commutators should be restricted.',
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
