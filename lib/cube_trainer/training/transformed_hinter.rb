# frozen_string_literal: true

require 'twisty_puzzles'

module CubeTrainer
  module Training
    # A hinter that works on algorithm hinters by applying the given transformation to all cases.
    class TransformedHinter
      def initialize(transformations, hinter)
        unless transformations.is_a?(Hash)
          raise TypeError,
                "Invalid transformations hash type #{transformations.class}."
        end
        unless hinter.respond_to?(:hints) && hinter.respond_to?(:entries)
          raise TypeError,
                "Invalid hinter type #{hinter.class}."
        end

        check_transformations(transformations)
        check_hinter(hinter)
        @transformations = transformations
        @hinter = hinter
      end

      def check_transformations(transformations)
        transformations.each_value do |transformation|
          unless transformation.is_a?(AlgorithmTransformation)
            raise TypeError,
                  "Invalid transformation type #{transformation.class}."
          end
        end
      end

      def check_hinter(hinter)
        hinter.entries.each do |algs|
          raise TypeError, "Invalid hints type #{algs.class}." unless algorithms.is_a?(Array)

          algs.each do |alg|
            raise TypeError, "Invalid hints type #{alg.class}." unless algorithm.is_a?(Algorithm)
          end
        end
      end

      def entries
        @entries ||=
          @hinter.entries.collect_concat do |alg_name, algs|
            @transformations.map do |transformation_name, transformation|
              name = transformation_name + alg_name
              transformed_algs = algs.map { |alg| transformation.transformed(alg) }
              [name, transformed_algs]
            end
          end
      end

      def hints(input)
        raise ArgumentError unless input.sub_names.length == 2

        transformation_name, alg_name = input.sub_names
        transformation = @transformations[transformation_name]
        algs = @hinter.hints(alg_name)
        algs.map { transformation.transformed(alg) }
      end
    end
  end
end
