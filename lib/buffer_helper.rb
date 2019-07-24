module CubeTrainer

  module BufferHelper

    def self.determine_buffer(part_type, options)
      if options.buffer
        options.letter_scheme.parse_buffer(part_type, options.buffer)
      else
        options.letter_scheme.default_buffer(part_type)
      end
    end

  end

end
