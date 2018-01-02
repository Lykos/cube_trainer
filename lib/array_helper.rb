module ArrayHelper
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
end
