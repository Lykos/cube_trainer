# frozen_string_literal: true

module CubeTrainer
  module Utils
    # Helper methods to construct SQL queries using Arel.
    module SqlHelper
      def check_exp(exp, optional: false)
        return if (optional && exp.nil?) || exp.is_a?(Arel::Node) || exp.is_a?(Arel::Attribute)

        raise TypeError
      end

      def array_agg(exp, order: nil)
        check_exp(exp)
        check_exp(order, optional: true)

        arg = order ? Arel::Nodes::InfixOperation.new('ORDER BY', exp, order) : exp
        Arel::Nodes::NamedFunction.new('ARRAY_AGG', [arg])
      end

      def floor(exp)
        check_exp(exp)

        Arel::Nodes::NamedFunction.new('FLOOR', [exp])
      end

      FIELDS = %i[
        century
        day
        decade
        dow
        doy
        epoch
        hour
        isodow
        isoyear
        microseconds
        millenium
        milliseconds
        minute
        month
        quarter
        second
        timezone
        timezone_hour
        timezone_minute
        week
        year
      ].freeze

      def extract(field, timestamp_or_interval)
        check_exp(timestamp_or_interval)
        raise ArgumentError unless FIELDS.include?(field)

        Arel::Nodes::Extract.new(timestamp_or_interval, Arel::Nodes::SqlLiteral.new(field.to_s))
      end

      # Can be used as `age(newer, older)` or `age(timestamp)`.
      def age(first_exp, second_exp = nil)
        check_exp(first_exp)
        check_exp(second_exp, optional: true)

        args = [first_exp]
        args.push(second_exp) if second_exp
        Arel::Nodes::NamedFunction.new('AGE', args)
      end
    end
  end
end
