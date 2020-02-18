# frozen_string_literal: true

require 'Qt4'
require 'cube_trainer/core/cube'

module CubeTrainer
  module Ui
    # Controller for the view that displays a cubie
    class CubieController
      PARTS = Core::Corner::ELEMENTS + Core::Edge::ELEMENTS

      def initialize(widget, color_scheme)
        @widget = widget
        @color_scheme = color_scheme
      end

      def scene
        @scene ||= begin
                     scene = Qt::GraphicsScene.new
                     @widget.setScene(scene)
                     scene
                   end
      end

      attr_reader :cubie

      def random_cubie
        PARTS.sample
      end

      def random_new_cubie
        return random_cubie unless @cubie

        new_cubie = @cubie
        new_cubie = random_cubie while new_cubie == @cubie
        new_cubie
      end

      def colors(cubie)
        cubie.face_symbols.map { |f| @color_scheme.color(f) }
      end

      def select_cubie
        scene.clear

        @cubie = random_new_cubie
        colors = cubie.class == Core::Corner ? colors(@cubie).rotate(2).reverse : colors(@cubie)
        colors.each_with_index { |c, i| add_to_scene(c, i, colors.length) }
        @widget.viewport.update
      end

      def add_to_scene(color, index, num_colors)
        b = brush(color)
        if num_colors == 2
          scene.addRect(rectangle(index), BLACK_PEN, b)
        elsif num_colors > 2
          scene.addPolygon(polygon(index, num_colors), BLACK_PEN, b)
        else
          raise ArgumentError, "Unsupported cubie size #{num_colors}."
        end
      end

      def brush(color)
        Qt::Brush.new(map_color(color))
      end

      BLACK_PEN = Qt::Pen.new(Qt.black)

      def cubie_size
        [@widget.size.height, @widget.size.width].min / 2
      end

      def point_on_circle(angle)
        Qt::PointF.new(cubie_size * Math.sin(angle), cubie_size * Math.cos(angle))
      end

      def rectangle(index)
        sign = [-1, 1][index]
        Qt::RectF.new(Qt::PointF.new(-cubie_size / 3, 0),
                      Qt::PointF.new(cubie_size / 3, sign * cubie_size * 2 / 3))
      end

      def polygon(index, number)
        angles = [angle(index, number), angle(index + 1, number)]
        corners = angles.collect { |a| point_on_circle(a) }
        corners.push(MIDDLE_POINT)
        Qt::PolygonF.new(corners)
      end

      MIDDLE_POINT = Qt::PointF.new(0.0, 0.0)

      def angle(index, number)
        index * 2 * Math::PI / number
      end

      def map_color(color)
        COLOR_MAP[color]
      end

      COLOR_MAP = {
        yellow: Qt.yellow,
        red: Qt.red,
        green: Qt.green,
        blue: Qt.blue,
        orange: Qt::Color.new(255, 165, 0),
        white: Qt.white
      }.freeze
    end
  end
end
