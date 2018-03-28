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
    COLOR_INFOS = {
      :yellow => ColorInfo.new(:reverse, :reverse, [2, 3, 0, 1]),
      :blue => ColorInfo.new(:keep, :reverse, [2, 0, 3, 1]),
      :red => ColorInfo.new(:keep, :reverse, [2, 0, 3, 1]),
      :green => ColorInfo.new(:keep, :keep, [1, 0, 3, 2]),
      :orange => ColorInfo.new(:keep, :keep, [1, 0, 3, 2]),
      :white => ColorInfo.new(:keep, :reverse, [2, 0, 3, 1])
    }
  
    def color_character(color, color_mode)
      raise ArgumentError, "Invalid color mode #{color_mode}" unless COLOR_MODES.include?(color_mode)
      char = color.to_s[0].upcase
      if color_mode == :color
        char.colorize(color_symbol(color))
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

    def face_lines(cube_state, color, color_mode)
      face = Face.for_color(color)
      color_info = COLOR_INFOS[color]
      stickers = cube_state.sticker_array(face)
      lines = stickers.collect do |sticker_line|
        line = sticker_line.collect { |c| color_character(c, color_mode) }.join
        maybe_reverse(color_info.reverse_columns_mode, line)
      end
      maybe_reverse(color_info.reverse_lines_mode, lines)
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
    def skewb_face_lines(cube_state, color, color_mode)
      face = Face.for_color(color)
      color_info = COLOR_INFOS[color]
      stickers = cube_state.sticker_array(face)
      center_color = color_character(stickers[0], color_mode)
      corner_colors = stickers[1..-1].collect { |c| color_character(c, color_mode) }
      permuted_corner_colors = apply_permutation(corner_colors, color_info.skewb_corner_permutation)
      raise unless corner_colors.length == 4
      skewb_ascii_art(center_color, permuted_corner_colors)
    end

    def cube_string(cube_state, color_mode)
      yellow_face = face_lines(cube_state, :yellow, color_mode)
      blue_face = face_lines(cube_state, :blue, color_mode)
      red_face = face_lines(cube_state, :red, color_mode)
      green_face = face_lines(cube_state, :green, color_mode)
      orange_face = face_lines(cube_state, :orange, color_mode)
      white_face = face_lines(cube_state, :white, color_mode)
      middle_belt = zip_concat_lines(blue_face, red_face, green_face, orange_face)
      lines = pad_lines(yellow_face, @n) + middle_belt + pad_lines(white_face, @n)
      lines.join("\n")
    end

    def skewb_string(cube_state, color_mode)
      yellow_face = skewb_face_lines(cube_state, :yellow, color_mode)
      blue_face = skewb_face_lines(cube_state, :blue, color_mode)
      red_face = skewb_face_lines(cube_state, :red, color_mode)
      green_face = skewb_face_lines(cube_state, :green, color_mode)
      orange_face = skewb_face_lines(cube_state, :orange, color_mode)
      white_face = skewb_face_lines(cube_state, :white, color_mode)
      middle_belt = zip_concat_lines(blue_face, red_face, green_face, orange_face)
      lines = pad_lines(yellow_face, SKEWB_FACE_SIZE) + middle_belt + pad_lines(white_face, SKEWB_FACE_SIZE)
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
