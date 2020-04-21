# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/color_scheme'

module CubeTrainer
  # Helper class to give a fingerprint for a Skewb layer.
  class SkewbLayerFingerprinter
    def initialize(face)
      raise ArgumentError unless face.is_a?(Core::Face)

      @face = face
    end

    # Returns a number that doesn't change from rotations around `face` or mirroring.
    # It tries to be different for different types of layers, but it's not perfect yet, so some
    # layers will be mapped to the same number.
    def fingerprint(skewb_state)
      Native.skewb_layer_fingerprint(skewb_state.native, @face.face_symbol)
    end
  end
end
