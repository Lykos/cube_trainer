# frozen_string_literal: true

require 'cube_trainer/anki/image_checker'
require 'cube_trainer/anki/cache'
require 'cube_trainer/anki/exponential_backoff'
require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/cube_constants'
require 'cube_trainer/core/move'
require 'cube_trainer/core/parser'
require 'cube_trainer/core/cube_print_helper'
require 'uri'

module CubeTrainer
  module Anki
    # Class that fetches images from
    # http://cube.crider.co.uk/visualcube.php
    class CubeVisualizer
      include Core::CubePrintHelper

      MIN_N = 1
      MAX_N = 10

      # Order of the faces for the color scheme
      FACE_SYMBOL_ORDER = %i[U R F D L B].freeze
      raise unless FACE_SYMBOL_ORDER.sort == Core::CubeConstants::FACE_SYMBOLS.sort

      BASE_MASKS = %i[fl f2l ll cll ell oll ocll oell coll ocell wv vh els cls cmll
                      cross f2l_3 f2l_2 f2l_sm f2l_1 f2b line 2x2x2 2x2x3].freeze
      STAGE_MASK_REGEXP = Regexp.new("(#{BASE_MASKS.join('|')})(?:-([xyz]['2]?+))?")

      # Helper class to serialize a URL parameter via invoking `#to_s`.
      class SimpleUrlParameterSerializer
        def serialize(value)
          value.to_s
        end
      end

      SIMPLE_URL_PARAMETER_SERIALIZER = SimpleUrlParameterSerializer.new

      # Helper class to serialize a color scheme as a URL paramer by setting the list of colors.
      class ColorSchemeUrlParameterSerializer
        def serialize(value)
          FACE_SYMBOL_ORDER.map { |s| value.color(s) }.join(',')
        end
      end

      # Stage mask that masks a certain part of the cube after applying moves.
      # This supports the same format as the cube visualizer website.
      class StageMask
        extend Core

        def initialize(base_mask, rotations = Core::Algorithm.empty)
          raise ArgumentError unless BASE_MASKS.include?(base_mask)
          raise TypeError unless rotations.is_a?(Core::Algorithm)
          raise TypeError unless rotations.moves.all? { |r| r.is_a?(Core::Rotation) }

          @base_mask = base_mask
          @rotations = rotations
        end

        attr_reader :base_mask, :rotations

        def self.parse(stage_mask_string)
          match = stage_mask_string.match(STAGE_MASK_REGEXP)
          if !match || !match.pre_match.empty? || !match.post_match.empty?
            raise ArgumentError, "Invalid stage mask #{stage_mask_string}."
          end

          raw_base_mask, raw_rotations = match.captures
          rotations = raw_rotations ? parse_algorithm(raw_rotations) : Core::Algorithm.empty
          StageMask.new(raw_base_mask.to_sym, rotations)
        end
      end

      COLOR_SCHEME_URL_PARAMETER_SERIALIZER = ColorSchemeUrlParameterSerializer.new

      # Helper class to serialize a stage mask as a URL paramer by setting the list of colors.
      class StageMaskUrlParameterSerializer
        def serialize(value)
          if value.rotations.empty?
            value.base_mask.to_s
          else
            "#{value.base_mask}-#{value.rotations.moves.join}"
          end
        end
      end

      STAGE_MASK_URL_PARAMETER_SERIALIZER = StageMaskUrlParameterSerializer.new

      # Represents one type of URL parameter.
      class UrlParameterType
        # rubocop:disable Metrics/ParameterLists
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def initialize(name,
                       type,
                       value_range,
                       parameter_value_serializer: SIMPLE_URL_PARAMETER_SERIALIZER,
                       default_value: nil,
                       required: false)
          raise TypeError unless name.is_a?(Symbol)
          raise TypeError unless type.is_a?(Class)
          raise TypeError unless value_range.respond_to?(:include?)
          raise TypeError unless default_value.nil? || default_value.is_a?(type)
          raise ArgumentError unless default_value.nil? || value_range.include?(default_value)
          raise TypeError unless parameter_value_serializer.respond_to?(:serialize)
          raise ArgumentError if default_value && required

          @name = name
          @type = type
          @serialized_default_value =
            default_value.nil? ? nil : parameter_value_serializer.serialize(default_value)
          @parameter_value_serializer = parameter_value_serializer
          @value_range = value_range
          @required = required
        end
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/ParameterLists

        attr_reader :name

        def extract(map)
          serialized_value = if (v = map[@name])
                               raise TypeError unless v.is_a?(@type)
                               unless @value_range.include?(v)
                                 raise ArgumentError, "Invalid value #{v} for parameter #{@name}."
                               end

                               @parameter_value_serializer.serialize(v)
                             elsif @required
                               raise ArgumentError, "Missing required parameter #{@name}."
                             else
                               @serialized_default_value
                             end
          [@name, serialized_value] if serialized_value
        end
      end

      # Represents a fake infinite range that includes everything.
      class FakeInfiniteRange
        def include?(_value)
          true
        end
      end

      FAKE_INFINITE_RANGE = FakeInfiniteRange.new

      COLORS = %i[black dgrey grey silver white yellow red orange blue green purple pink].freeze

      URL_PARAMETER_TYPES = [
        UrlParameterType.new(:fmt, Symbol, %i[png gif jpg svg tiff ico], required: true),
        UrlParameterType.new(:size, Integer, (0..1024)),
        UrlParameterType.new(:view, Symbol, %i[plain trans]),
        UrlParameterType.new(:stage, StageMask, FAKE_INFINITE_RANGE,
                             parameter_value_serializer: STAGE_MASK_URL_PARAMETER_SERIALIZER),
        UrlParameterType.new(:sch, ColorScheme, FAKE_INFINITE_RANGE,
                             required: true,
                             parameter_value_serializer: COLOR_SCHEME_URL_PARAMETER_SERIALIZER),
        UrlParameterType.new(:bg, Symbol, COLORS),
        UrlParameterType.new(:cc, Symbol, COLORS),
        UrlParameterType.new(:co, Integer, (0..99)),
        UrlParameterType.new(:fo, Integer, (0..99)),
        UrlParameterType.new(:dist, Integer, (1..100))
        # TODO: arw
        # TODO ac
      ].freeze

      URL_PARAMETER_TYPE_KEYS = URL_PARAMETER_TYPES.map(&:name)

      # Stub cache that caches nothing.
      class StubCache
        def [](_key)
          nil
        end

        def []=(key, value); end
      end

      def check_param_keys(keys)
        invalid_keys = keys - URL_PARAMETER_TYPE_KEYS
        return if invalid_keys.empty?

        raise ArgumentError, "Unknown url parameter keys #{invalid_keys.join(', ')}"
      end

      def check_cache(cache)
        raise TypeError unless cache.nil? || (cache.respond_to?(:[]) && cache.respond_to?(:[]=))
      end

      def check_checker(checker)
        raise TypeError unless checker.nil? || checker.respond_to?(:valid?)
      end

      def extract_url_params(params)
        URL_PARAMETER_TYPES.map { |p| p.extract(params) }.compact
      end

      def extract_color_scheme(params)
        params[:sch] || (raise ArgumentError)
      end

      def extract_format(params)
        params[:fmt] || (raise ArgumentError)
      end

      def initialize(fetcher:, cache: nil, retries: 5, checker: nil, **params)
        check_param_keys(params.keys)
        check_cache(cache)
        check_checker(checker)
        raise TypeError unless fetcher.respond_to?(:get)
        raise TypeError unless retries.is_a?(Integer)
        raise ArgumentError if retries.negative?

        @fetcher = fetcher
        @cache = cache || StubCache.new
        @retries = retries
        @url_params = extract_url_params(params)
        @color_scheme = extract_color_scheme(params)
        format = extract_format(params)
        @checker = checker || ImageChecker.new(format)
      end

      BASE_URI = URI('http://cube.crider.co.uk/visualcube.php')

      def serialize_color(color)
        case color
        when :transparent then 't'
        when :unknown then 'n'
        when :oriented then 'o'
        else @color_scheme.face_symbol(color).to_s.downcase
        end
      end

      def cube_state_params(cube_state)
        raise TypeError unless cube_state.is_a?(Core::CubeState)
        raise ArgumentError unless MIN_N <= cube_state.n && cube_state.n <= MAX_N

        serialized_cube_state = FACE_SYMBOL_ORDER.map do |s|
          face_lines(cube_state, s, &method(:serialize_color)).flatten.join
        end.join
        [
          [:pzl, cube_state.n],
          [:fd, serialized_cube_state]
        ]
      end

      def uri(cube_state)
        uri = BASE_URI.dup
        uri.query = URI.encode_www_form(@url_params + cube_state_params(cube_state))
        uri
      end

      def really_fetch_internal(uri)
        backoff = ExponentialBackoff.new
        data = @fetcher.get(uri)
        return data if @checker.valid?(data)

        @retries.times do
          sleep(backoff.next_backoff_s)
          data = @fetcher.get(uri)
          return data if @checker.valid?(data)
        end
        raise "Didn't get a valid image after #{@retries} retries."
      end

      def fetch(cube_state)
        uri = uri(cube_state)
        if (r = @cache[uri.to_s])
          r
        else
          @cache[uri.to_s] = really_fetch_internal(uri)
        end
      end

      def fetch_and_store(cube_state, output)
        image = fetch(cube_state)
        File.open(output, 'wb') { |f| f.write(image) }
      end
    end
  end
end
