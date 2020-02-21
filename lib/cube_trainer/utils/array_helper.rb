# frozen_string_literal: true

module CubeTrainer
  module Utils
    # A few array related helper methods.
    module ArrayHelper
      def apply_permutation(array, permutation)
        raise ArgumentError unless array.length == permutation.length
        raise ArgumentError unless permutation.uniq.length == permutation.length

        permutation.map do |i|
          raise ArgumentError unless i.is_a?(Integer) && i >= 0 && i < array.length

          array[i]
        end
      end

      def turned_equals?(left, right)
        return false if left.length != right.length

        (0...left.length).any? do |r|
          return true if left.rotate(r) == right
        end
        false
      end

      private

      def next_state_after_nil(array, state)
        case state
        when :start then :first_nil_part
        when :first_part then :nil_middle
        when :middle then :second_nil_part
        when :first_nil_part, :second_nil_part, :nil_middle then state
        when :second_part
          raise ArgumentError,
                "Cannot rotate out nils for #{array.inspect} since the nils are not contiguous."
        else raise "Unknown state #{state} reached."
        end
      end

      def next_state_after_non_nil(array, state)
        case state
        when :start then :first_part
        when :first_nil_part then :middle
        when :nil_middle then :second_part
        when :first_part, :second_part, :middle then state
        when :second_nil_part
          raise ArgumentError,
                "Cannot rotate out nils for #{array.inspect} since the nils are not contiguous."
        else raise "Unknown state #{state} reached."
        end
      end

      def next_state(state, array, element, first_part, second_part)
        if element.nil?
          next_state_after_nil(array, state)
        else
          state = next_state_after_non_nil(array, state)
          current_part = state == :second_part ? second_part : first_part
          current_part.push(element)
          state
        end
      end

      public

      def rotate_out_nils(array)
        first_part = []
        second_part = []
        # Valid input goes either start -> first_part -> nil_middle -> second_part
        # or start -> first_nil_part -> middle -> second_nil_part
        state = :start
        array.each do |element|
          state = next_state(state, array, element, first_part, second_part)
        end
        second_part + first_part
      end

      def check_types(array, type)
        array.each { |e| raise TypeError unless e.is_a?(type) }
      end

      # Returns the only element of an array and raises if the array has not exactly one element.
      def only(array)
        raise ArgumentError, "Can't take the only element of an empty array." if array.empty?

        unless array.length == 1
          raise ArgumentError,
                "Can't take the only element of an array with #{array.length} elements."
        end

        array[0]
      end

      def find_only(array, &block)
        only(array.select(&block))
      end

      def replace_once(array, old_element, new_element)
        raise ArgumentError unless array.count { |e| e == old_element } == 1

        new_array = array.dup
        new_array[new_array.index(old_element)] = new_element
        new_array
      end
    end
  end
end
