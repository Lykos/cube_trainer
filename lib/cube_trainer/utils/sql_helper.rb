# frozen_string_literal: true

module CubeTrainer
  module Utils
    # Helper methods to construct SQL queries using Arel.
    module SqlHelper
      def array_agg(exp, order: nil)
        raise TypeError unless exp.is_a?(Arel::Node)
        raise TypeError unless order.nil? || order.is_a?(Arel::Node)

        arg = order ? Arel::Nodes::InfixOperation.new('ORDER BY', exp, order) : exp
        Arel::Nodes::NamedFunction.new('ARRAY_AGG', [arg])
      end

      def floor(exp)
        raise TypeError unless exp.is_a?(Arel::Node)

        Arel::Nodes::NamedFunction.new('FLOOR', [exp])
      end

      FIELDS = [
        :century,
        :day,
        :decade,
        :dow,
        :doy,
        :epoch,
        :hour,
        :isodow,
        :isoyear,
        :microseconds,
        :millenium,
        :milliseconds,
        :minute,
        :month,
        :quarter,
        :second,
        :timezone,
        :timezone_hour,
        :timezone_minute,
        :week,
        :year
      ].freeze

      def extract(field, timestamp_or_interval)
        raise ArgumentError unless FIELDS.include?(field)
        raise TypeError unless timestamp_or_interval.is_a?(Arel::Node)

        Arel::Nodes::Extract.new(timestamp_or_interval, Arel::Nodes::SqlLiteral.new(field.to_s));
      end

      # Can be used as `age(newer, older)` or `age(timestamp)`.
      def age(first_exp, second_exp = nil)
        raise TypeError unless first_exp.is_a?(Arel::Node)
        raise TypeError unless second_exp.nil? || exp.is_a?(Arel::Node)

        args = [first_exp]
        args.push(second_exp) if second_exp
        Arel::Nodes::NamedFunction.new('AGE', args)
      end
    end
  end
end
