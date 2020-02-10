require 'cube_trainer/cube_print_helper'
require 'cube_trainer/cube'
require 'cube_trainer/cube_constants'
require 'cube_trainer/coordinate'
require 'cube_trainer/color_scheme'

module CubeTrainer

  class SkewbLayerFingerprinter

    def initialize(face)
      raise ArgumentError unless face.is_a?(Face)
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
