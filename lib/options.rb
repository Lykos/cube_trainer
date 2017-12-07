require 'optparse'
require 'ostruct'
  
class Options
  CommutatorInfo = Struct.new(:result_symbol, :generator_class)
  COMMUTATOR_TYPES = {
    "corners" => CommutatorInfo.new(:corner_commutators, CornerCommutators),
    "edges" => CommutatorInfo.new(:edge_commutators, EdgeCommutators)
  }
  
  def self.parse(args)
    options = OpenStruct.new
    options.commutator_info = COMMUTATOR_TYPES["corners"] 
    opt_parser = OptionParser.new do |opts|
      opts.separator ""
      opts.separator "Specific options:"      
      opts.on("-c", "--commutator_type TYPE", COMMUTATOR_TYPES) do |info|
        options.commutator_info = info
      end

      opts.on("-r" "--restrict LETTERLIST", /[a-x]+/) do |letters|
        options.restrict_letters = letters.split("")
      end
      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end   
    end
    opt_parser.parse!(args)
    options
  end
end
