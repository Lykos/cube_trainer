module CubeTrainer

  class SkewbLayerFinder
    POSSIBLE_MOVES = ['U', 'U\'', 'R', 'R\'', 'L', 'L\'', 'B', 'B\''].collect { |m| parse_skewb_move(m) }

    def layer_score(skewb_state)
      Face::ELEMENTS.collect { |f| layer_score_on_face(skewb_state, f) }.max
    end

    def random_sequence(n)
      Algorithm.new((0...n).collect { POSSIBLE_MOVES.sample })
    end

    def layer_score_on_face(skewb_state, face)
      face_color = skewb_state[SkewbCoordinate.center(face)]
      skewb_state.sticker_array(face)[1..-1].count { |c| c == face_color }
    end

    def find_layer(skewb_state, limit)
      raise ArgumentError unless limit.is_a?(Integer) && limit >= 0
      if skewb_state.any_layer_solved?
        return [Algorithm.empty]
      end
      if limit == 0
        return []
      end
      moves = POSSIBLE_MOVES.dup.sort_by do |m|
        m.apply_to(skewb_state)
        score = layer_score(skewb_state)
        m.invert.apply_to(skewb_state)
        score
      end.reverse
      best_solutions = []
      inner_limit = limit - 1
      moves.each do |m|
        m.apply_to(skewb_state)
        # Note that limit is updated s.t. this solution helps us.
        solutions = find_layer(skewb_state, inner_limit)
        m.invert.apply_to(skewb_state)
        if !solutions.empty? then
          if solutions.first.length < inner_limit
            best_solutions.clear
            inner_limit = solutions.first.length
          end
          best_solutions += solutions.collect { |s| Algorithm.new([m]) + s }
          break if inner_limit < 0
        end
      end
      best_solutions
    end
  end
  
end
