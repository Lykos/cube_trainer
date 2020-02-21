# frozen_string_literal: true

module CubeTrainer
  # Module that contains methods to extract the mode and buffer from an options struct.
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
      buffer_result =
        if info.has_buffer? && info.generator_class.const_defined?(:PART_TYPE)
          part_type = info.generator_class::PART_TYPE
          buffer = determine_buffer(part_type, options)
          (buffer.to_s.downcase + '_' + info.result_symbol.to_s).to_sym
        else
          info.result_symbol
                             end
      options.picture ? (buffer_result.to_s + '_pic').to_sym : buffer_result
    end
  end
end
