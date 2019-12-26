module CubeTrainer

  module BufferHelper

    def self.determine_buffer(part_type, options)
      if options.buffer
        options.letter_scheme.parse_buffer(part_type, options.buffer)
      else
        options.letter_scheme.default_buffer(part_type)
      end
    end

    def self.mode_for_options(options)
      info = options.commutator_info
      buffer_result =  if info.has_buffer? and info.generator_class.const_defined?(:PART_TYPE)
                         part_type = info.generator_class::PART_TYPE
                         buffer = determine_buffer(part_type, options)
                         (buffer.to_s.downcase + '_' + info.result_symbol.to_s).to_sym
                       else
                         info.result_symbol
                       end
      if options.picture then (buffer_result.to_s + '_pic').to_sym else buffer_result end
    end

  end

end
