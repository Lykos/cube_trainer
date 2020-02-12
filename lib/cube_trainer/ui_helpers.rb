# frozen_string_literal: true

module CubeTrainer
  module UiHelpers
    def format_time(time_s)
      format('%<time_s>.2f', time_s: time_s)
    end
  end
end
