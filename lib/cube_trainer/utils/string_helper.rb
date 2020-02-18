# frozen_string_literal: true

module CubeTrainer
  module Utils
    # A few string related helper methods.
    module StringHelper
      def camel_case_to_snake_case(camel_case)
        camel_case.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                  .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                  .downcase
      end

      def simple_class_name(clazz)
        clazz.name.split('::').last
      end

      def snake_case_class_name(clazz)
        camel_case_to_snake_case(simple_class_name(clazz))
      end
    end
  end
end
