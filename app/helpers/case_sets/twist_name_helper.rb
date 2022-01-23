module CaseSets
  module TwistNameHelper
    def twist_name(twist_cycle)
      raise TypeError unless twist_cycle.is_a?(PartCycle)
      raise ArgumentError unless twist_cycle.length == 1 && twist_cycle.twist > 0

      "#{twist_name(twist_cycle)} #{twist_cycle.parts.first}#{twist_suffix(twist_cycle)}"
    end

    private
    
    def twist_word(twist_cycle)
      direction_matters?(twist_cycle) ? 'twist' : 'flip'
    end

    def twist_suffix(twist_cycle)
      direction_matters?(twist_cycle) ? " #{twist_direction_name}" : ''
    end

    def direction_matters?(twist_cycle)
      twist_cycle.parts[0].rotations.length > 1
    end

    def twist_direction_name(twist_cycle)
      case twist_cycle.twist
      when 1 then 'cw'
      when 2 then 'ccw'
      else raise ArgumentError
      end
    end
  end
end
