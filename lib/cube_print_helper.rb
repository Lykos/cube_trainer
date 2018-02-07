require 'colorize'

module CubeTrainer
  
  module CubePrintHelper
    def color_symbol(color)
      if color == :orange then :light_red else color end
    end

    COLOR_MODES = [:color, :nocolor]
    ColorInfo = Struct.new(:reverse_lines_mode, :reverse_columns_mode)
    COLOR_INFOS = {
      :yellow => ColorInfo.new(:reverse, :reverse),
      :blue => ColorInfo.new(:keep, :reverse),
      :red => ColorInfo.new(:keep, :reverse),
      :green => ColorInfo.new(:keep, :keep),
      :orange => ColorInfo.new(:keep, :keep),
      :white => ColorInfo.new(:keep, :reverse)
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
