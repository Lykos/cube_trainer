module CubeTrainer

  module ArrayHelper

    def apply_permutation(array, permutation)
      raise ArgumentError unless array.length == permutation.length
      raise ArgumentError unless permutation.uniq.length == permutation.length
      permutation.collect do |i|
        raise ArgumentError unless i.is_a?(Integer) && 0 <= i && i < array.length
        array[i]
      end
    end

    def turned_equals?(a, b)
      return false if a.length != b.length
      (0...a.length).any? do |r|
        return true if a.rotate(r) == b
      end
      return false
    end

    def rotate_out_nils(array)
      first_part = []
      second_part = []
      # Valid input goes either start -> first_part -> nil_middle -> second_part
      # or start -> first_nil_part -> middle -> second_nil_part
      state = :start
      array.each do |a|
        if a.nil?
          case state
          when :start
            state = :first_nil_part
          when :first_part
            state = :nil_middle
          when :middle
            state = :second_nil_part
          when :first_nil_part, :second_nil_part, :nil_middle
            # Nop
          when :second_part
            raise ArgumentError, "Cannot rotate out nils for #{array.inspect} since the nils are not contiguous."
          else
            raise "Unknown state #{state} reached."
          end
        else
          case state
          when :start
            state = :first_part
          when :first_nil_part
            state = :middle
          when :nil_middle
            state = :second_part
          when :first_part, :second_part, :middle
            # Nop
          when :second_nil_part
            raise ArgumentError, "Cannot rotate out nils for #{array.inspect} since the nils are not contiguous."
          else
            raise "Unknown state #{state} reached."
          end
          current_part = if state == :second_part then second_part else first_part end
          current_part.push(a)
        end
      end
      second_part + first_part
    end

    # Returns the only element of an array and raises if the array has not exactly one element.
    def only(array)
      raise ArgumentError, "Can't take the only element of an empty array." if array.empty?
      raise ArgumentError, "Can't take the only element of an array with #{array.length} elements." unless array.length == 1
      array[0]
    end

    def replace_once(array, old_element, new_element)
      raise ArgumentError unless array.count { |e| e == old_element } == 1
      new_array = array.dup
      new_array[new_array.index(old_element)] = new_element
      new_array
    end
          
  end

end
