require 'colorize'
require 'array_helper'

module CubeTrainer
  
  module CubePrintHelper
    include ArrayHelper
    
    def color_symbol(color)
      if color == :orange then :light_red else color end
    end

    COLOR_MODES = [:color, :nocolor]
    ColorInfo = Struct.new(:reverse_lines_mode, :reverse_columns_mode, :skewb_corner_permutation)
    FACE_SYMBOL_INFOS = {
      :U => ColorInfo.new(:reverse, :reverse, [2, 3, 0, 1]),
      :L => ColorInfo.new(:keep, :reverse, [2, 0, 3, 1]),
      :F => ColorInfo.new(:keep, :reverse, [2, 0, 3, 1]),
      :R => ColorInfo.new(:keep, :keep, [1, 0, 3, 2]),
      :B => ColorInfo.new(:keep, :keep, [1, 0, 3, 2]),
      :D => ColorInfo.new(:keep, :reverse, [2, 0, 3, 1])
    }
  
    def color_character(color, color_mode)
      raise ArgumentError, "Invalid color mode #{color_mode}" unless COLOR_MODES.include?(color_mode)
      char = color.to_s[0].upcase
      if color_mode == :color
        char.colorize(:background => color_symbol(color))
      else
        char
      end
    end

    def maybe_reverse(reverse_mode, stuff)
      if reverse_mode == :reverse
        stuff.reverse
      elsif reverse_mode == :keep
        stuff
      else
        raise
      end
    end

    def face_lines(cube_state, face_symbol, color_mode, row_multiplicity=1, column_multiplicity=1)
      face = Face.for_face_symbol(face_symbol)
      face_symbol_info = FACE_SYMBOL_INFOS[face_symbol]
      stickers = cube_state.sticker_array(face)
      lines = stickers.collect_concat do |sticker_line|
        line = sticker_line.collect { |c| color_character(c, color_mode) * column_multiplicity }
        [maybe_reverse(face_symbol_info.reverse_columns_mode, line).join] * row_multiplicity
      end
      maybe_reverse(face_symbol_info.reverse_lines_mode, lines)
    end

    SKEWB_FACE_SIZE = 5

    def skewb_ascii_art_line(first_color, middle_color, last_color, num_first_color)
      raise if num_first_color > SKEWB_FACE_SIZE / 2
      first_color * num_first_color + middle_color * (SKEWB_FACE_SIZE - 2 * num_first_color) + last_color * num_first_color
    end

    def skewb_ascii_art(center_color, corner_colors)
      raise unless corner_colors.length == 4
      first_part = (1..SKEWB_FACE_SIZE / 2).to_a.reverse.collect do |i|
        skewb_ascii_art_line(corner_colors[0], center_color, corner_colors[1], i)
      end
      middle_part = if SKEWB_FACE_SIZE % 2 == 1 then [center_color * SKEWB_FACE_SIZE] else [] end
      last_part = (1..SKEWB_FACE_SIZE / 2).collect do |i|
        skewb_ascii_art_line(corner_colors[2], center_color, corner_colors[3], i)
      end
      first_part + middle_part + last_part
    end

    # Prints a Skewb face like this:
    # rrgww
    # rgggw
    # ggggg
    # ogggb
    # oogbb
    def skewb_face_lines(cube_state, face_symbol, color_mode)
      face = Face.for_face_symbol(face_symbol)
      face_symbol_info = FACE_SYMBOL_INFOS[face_symbol]
      stickers = cube_state.sticker_array(face)
      center_color = color_character(stickers[0], color_mode)
      corner_colors = stickers[1..-1].collect { |c| color_character(c, color_mode) }
      permuted_corner_colors = apply_permutation(corner_colors, face_symbol_info.skewb_corner_permutation)
      raise unless corner_colors.length == 4
      skewb_ascii_art(center_color, permuted_corner_colors)
    end

    def ll_string(cube_state, color_mode)
      top_face = face_lines(cube_state, :U, color_mode, 2, 3)
      front_face = face_lines(cube_state, :F, color_mode, 1, 3)
      right_face = face_lines(cube_state, :R, color_mode, 1, 3)
      pll_line = front_face.first + right_face.first
      (top_face + [pll_line] * 3).join("\n")
    end

    def cube_string(cube_state, color_mode)
      top_face = face_lines(cube_state, :U, color_mode)
      left_face = face_lines(cube_state, :L, color_mode)
      front_face = face_lines(cube_state, :F, color_mode)
      right_face = face_lines(cube_state, :R, color_mode)
      back_face = face_lines(cube_state, :B, color_mode)
      bottom_face = face_lines(cube_state, :D, color_mode)
      middle_belt = zip_concat_lines(left_face, front_face, right_face, back_face)
      lines = pad_lines(top_face, cube_state.n) + middle_belt + pad_lines(bottom_face, cube_state.n)
      lines.join("\n")
    end

    def skewb_string(cube_state, color_mode)
      top_face = skewb_face_lines(cube_state, :U, color_mode)
      left_face = skewb_face_lines(cube_state, :L, color_mode)
      front_face = skewb_face_lines(cube_state, :F, color_mode)
      right_face = skewb_face_lines(cube_state, :R, color_mode)
      back_face = skewb_face_lines(cube_state, :B, color_mode)
      bottom_face = skewb_face_lines(cube_state, :D, color_mode)
      middle_belt = zip_concat_lines(left_face, front_face, right_face, back_face)
      lines = pad_lines(top_face, SKEWB_FACE_SIZE) + middle_belt + pad_lines(bottom_face, SKEWB_FACE_SIZE)
      lines.join("\n")
    end

    def empty_name
      ' '
    end

    def pad_lines(lines, n)
      lines.collect { |line| empty_name * n + line }
    end

    def zip_concat_lines(*args)
      args[0].zip(*args[1..-1]).collect { |lines| lines.join }
    end
  end
  
end
