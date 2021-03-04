# frozen_string_literal: true

module CubeTrainer
  module Scraping
    F2lCase =
      Struct.new(:name, :has_auf, :has_corner_direction, :orientation_mode) do
        def orientation?
          orientation_mode == :default_is_oriented || orientation_mode == :default_is_misoriented
        end

        def oriented_index
          case orientation_mode
          when :default_is_oriented then 0
          when :default_is_misoriented then 1
          else raise
          end
        end

        def misoriented_index
          1 - oriented_index
        end
      end

    F2L_CASES = [
      nil,
      F2lCase.new('wall', true, false, :default_is_oriented),
      F2lCase.new('roof', true, false, :default_is_oriented),
      F2lCase.new('checkerboard', true, false, :default_is_oriented),
      F2lCase.new('triple sexy', true, false, :only_oriented),
      F2lCase.new('weird watcher', true, true, :only_misoriented),
      F2lCase.new('solved edge', true, true, :only_oriented),
      F2lCase.new('free pair', true, false, :default_is_misoriented),
      F2lCase.new('flipped pair', true, false, :only_misoriented),
      F2lCase.new('friend', true, false, :default_is_misoriented),
      F2lCase.new('split', true, false, :default_is_misoriented),
      F2lCase.new('short hide', true, false, :default_is_oriented),
      F2lCase.new('long hide', true, false, :default_is_oriented),
      F2lCase.new('three mover', true, false, :default_is_misoriented),
      F2lCase.new('pseudo three mover', true, false, :default_is_misoriented),
      F2lCase.new('long penis', true, false, :default_is_oriented),
      F2lCase.new('short penis', true, false, :default_is_oriented),
      F2lCase.new('solved corner', true, false, :default_is_oriented),
      F2lCase.new('hockey stick', true, false, :default_is_oriented),
      F2lCase.new('broken hockey stick', true, false, :default_is_misoriented),
      F2lCase.new('twisted corner', false, true, :only_oriented),
      F2lCase.new('ugly stuck pieces', false, true, :only_misoriented),
      F2lCase.new('flipped edge', false, false, :only_misoriented)
    ].freeze

    # Description of one specific F2l case, counting the following as different cases:
    # * Different position of the pieces relative to each other.
    # * Different slots
    # * Different orientations
    # * Different AUFs
    F2lCaseDescription =
      Struct.new(:f2l_case_index, :slot, :subcase_index, :aufcase_index) do
        def aufcase_suffix
          case aufcase_index
          when 1 then ' + U\''
          when 2 then ' + U2'
          when 3 then ' + U'
          else ''
          end
        end

        def inspect
          "#{self.class}(#{f2l_case_index}, '#{slot}', #{subcase_index}, #{aufcase_index})"
        end

        def back_front
          slot[0] == 'f' ? 'front' : 'back'
        end

        def corner_suffix
          return '' unless f2l_case.has_corner_direction

          case corner_index
          when 0 then " corner in #{back_front}"
          when 1 then ' corner on side'
          else raise
          end
        end

        def corner_index
          if !f2l_case.has_auf
            aufcase_index
          elsif !f2l_case.orientation?
            subcase_index
          else
            raise
          end
        end

        def f2l_case
          @f2l_case ||= F2L_CASES[f2l_case_index]
        end

        def orientation_suffix
          return '' unless f2l_case.orientation?

          case subcase_index
          when f2l_case.oriented_index then ' oriented'
          when f2l_case.misoriented_index then ' misoriented'
          else raise
          end
        end

        def to_s
          "#{f2l_case.name} #{slot}#{orientation_suffix}#{corner_suffix}#{aufcase_suffix}"
        end
      end
  end
end
