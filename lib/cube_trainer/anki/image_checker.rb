# frozen_string_literal: true

require 'filemagic'

module CubeTrainer
  module Anki
    # Class that checks whether an image is invalid.
    # Note that this is not very good currently.
    # It just checks very obvious things.
    class ImageChecker
      def initialize(format)
        @format = format
        @magic = FileMagic.new
      end

      def valid?(data)
        info = @magic.buffer(data)
        case @format
        when :jpg
          info.start_with?('JPEG')
        else
          raise NotImplementedError
        end
      end
    end
  end
end
