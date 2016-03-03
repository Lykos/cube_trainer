require 'Qt4'
require 'cube'

class CubieController

  def initialize(widget)
    @widget = widget
  end

  def scene
    @scene ||= create_scene
  end

  def create_scene
    scene = Qt::GraphicsScene.new
    @widget.setScene(scene)
    scene
  end

  private :create_scene

  attr_reader :cubie

  def select_cubie
    scene.clear
    @cubie = random_cubie
    colors = @cubie.colors
    colors.each_with_index { |c, i| add_to_scene(c, i, colors.length) }
  end

  def add_to_scene(c, i, n)
    if n == 2
      scene.addRect(rectangle(i), BLACK_PEN, brush(c))
    elsif n > 2
      scene.addPolygon(polygon(i, n), BLACK_PEN, brush(c))
    else
      raise "Unsupported cubie size #{n}."
    end
  end

  def brush(c)
    Qt::Brush.new(map_color(c))
  end

  BLACK_PEN = Qt::Pen.new(Qt::black)

  def cubie_size
    [@widget.size.height, @widget.size.width].min / 2
  end

  def point_on_circle(angle)
    Qt::PointF.new(cubie_size * Math.sin(angle), cubie_size * Math.cos(angle))
  end

  def rectangle(i)
    outer_bound = [cubie_size, -cubie_size][i]
    Qt::RectF.new(-cubie_size, 0, cubie_size, outer_bound)
  end

  def polygon(i, n)
    angles = [angle(i, n), angle(i + 1, n)]
    corners = angles.collect { |a| point_on_circle(a) }
    corners.push(MIDDLE_POINT)
    Qt::PolygonF.new(corners)
  end

  MIDDLE_POINT = Qt::PointF.new(0.0, 0.0)

  def angle(i, n)
    i * 2 * Math::PI / n
  end

  def map_color(color)
    COLOR_MAP[color]
  end

  COLOR_MAP = {
    :yellow => Qt::yellow,
    :red => Qt::red,
    :green => Qt::green,
    :blue => Qt::blue,
    :orange => Qt::Color.new(255, 165, 0),
    :white => Qt::white
  }
end
