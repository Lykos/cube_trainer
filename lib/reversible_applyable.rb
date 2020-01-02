module CubeTrainer

  module ReversibleApplyable

    def apply_temporarily_to(cube_state, &block)
      apply_to(cube_state)
      begin
        yield
      ensure
        inverse.apply_to(cube_state)
      end
    end

  end

end
