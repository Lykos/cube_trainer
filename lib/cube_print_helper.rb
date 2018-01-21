require 'colorize'

module CubePrintHelper
  def colorize_color(color)
    if color == :orange then :light_red else color end
  end
  
  def color_name(color)
    color.to_s[0].upcase
  end

  def stickers_to_lines(stickers, reverse_lines, reverse_columns)
    lines = stickers.collect do |sticker_line|
      line = sticker_line.collect { |c| color_name(c) }.join
      if reverse_columns then line.reverse else line end
    end
    if reverse_lines then lines.reverse else lines end
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
