module CubeTrainer

  module BufferHelper

    def self.determine_buffer(part_type, options)
      if options.buffer
        options.letter_scheme.parse_buffer(part_type, options.buffer)
      else
        options.letter_scheme.default_buffer(part_type)
      end
    end

    def self.mode_for_buffer(options)
      info = options.commutator_info
      if info.has_buffer? and info.generator_class.const_defined?(:PART_TYPE)
        part_type = info.generator_class::PART_TYPE
        buffer = determine_buffer(part_type, options)
        (buffer.to_s.downcase + '_' + info.result_symbol.to_s).to_sym
      else
        info.result_symbol
      end
    end

  end

end
