require 'uri'
require 'cube_trainer/cube_constants'
require 'cube_trainer/cube_print_helper'
require 'cube_trainer/color_scheme'
require 'cube_trainer/anki/cache'

module CubeTrainer

  class CubeVisualizer

    include CubePrintHelper

    MIN_N = 1
    MAX_N = 10
    
    # Order of the faces for the color scheme
    FACE_SYMBOL_ORDER = [:U, :R, :F, :D, :L, :B]
    raise unless FACE_SYMBOL_ORDER.sort == CubeConstants::FACE_SYMBOLS.sort

    # Order of the faces for the state scheme
    FACE_ORDER = [:U, :F, :R, :B, :L, :D]
    raise unless FACE_ORDER.sort == CubeConstants::FACE_SYMBOLS.sort

    class SimpleUrlParameterSerializer
      def serialize(value)
        value.to_s
      end
    end

    SIMPLE_URL_PARAMETER_SERIALIZER = SimpleUrlParameterSerializer.new    

    class ColorSchemeUrlParameterSerializer
      def serialize(value)
        FACE_SYMBOL_ORDER.map { |s| value.color(s) }.join(',')
      end
    end

    COLOR_SCHEME_URL_PARAMETER_SERIALIZER = ColorSchemeUrlParameterSerializer.new

    class UrlParameterType
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
        @serialized_default_value = default_value.nil? ? nil : parameter_value_serializer.serialize(default_value)
        @parameter_value_serializer = parameter_value_serializer
        @value_range = value_range
        @required = required
      end

      attr_reader :name
      
      def extract(map)
        serialized_value = if v = map[@name]
                             raise TypeError unless v.is_a?(@type)
                             raise ArgumentError, "Invalid value #{v} for parameter #{@name}." unless @value_range.include?(v)
                             @parameter_value_serializer.serialize(v)
                           elsif @required
                             raise ArgumentError, "Missing required parameter #{@name}."
                           else
                             @serialized_default_value
                           end
        [@name, serialized_value] if serialized_value
      end
    end

    class FakeInfiniteRange
      def include?(value)
        true
      end
    end

    FAKE_INFINITE_RANGE = FakeInfiniteRange.new

    COLORS = [:black, :dgrey, :grey, :silver, :white, :yellow, :red, :orange, :blue, :green, :purple, :pink]
    
    URL_PARAMETER_TYPES = [
      UrlParameterType.new(:fmt, Symbol, [:png, :gif, :jpg, :svg, :tiff, :ico], required: true),
      UrlParameterType.new(:size, Integer, (0..1024)),
      UrlParameterType.new(:view, Symbol, [:plain, :trans]),
      UrlParameterType.new(:sch, ColorScheme, FAKE_INFINITE_RANGE, required: true, parameter_value_serializer: COLOR_SCHEME_URL_PARAMETER_SERIALIZER),
      UrlParameterType.new(:bg, Symbol, COLORS),
      UrlParameterType.new(:cc, Symbol, COLORS),
      UrlParameterType.new(:co, Integer, (0..99)),
      UrlParameterType.new(:fo, Integer, (0..99)),
      UrlParameterType.new(:dist, Integer, (1..100)),
      # TODO arw
      # TODO ac
    ]

    URL_PARAMETER_TYPE_KEYS = URL_PARAMETER_TYPES.map { |t| t.name }

    class StubCache
      def [](key)
        nil
      end

      def []=(key, value)
      end
    end

    def initialize(fetcher, cache, **params)
      raise TypeError unless fetcher.respond_to?(:get)
      @fetcher = fetcher
      raise TypeError unless cache.nil? || (cache.respond_to?(:[]) && cache.respond_to?(:[]=))
      @cache = cache || StubCache.new
      invalid_keys = params.keys - URL_PARAMETER_TYPE_KEYS
      raise ArgumentError, "Unknown url parameter keys #{invalid_keys.join(', ')}" unless invalid_keys.empty?
      @params = URL_PARAMETER_TYPES.map { |p| p.extract(params) }.select { |p| p }
      @color_scheme = params[:sch] || (raise ArgumentError)
    end

    BASE_URI = URI("http://cube.crider.co.uk/visualcube.php")

    def cube_state_params(cube_state)
      raise TypeError unless cube_state.is_a?(CubeState)
      raise ArgumentError unless MIN_N <= cube_state.n && cube_state.n <= MAX_N
      serialized_cube_state = FACE_ORDER.map do |s| 
        face_lines(cube_state, s) do |c|
          @color_scheme.face_symbol(c).to_s.downcase
        end.flatten.join
      end.join
      extra_params = [
        [:pzl, cube_state.n],
        [:fd, serialized_cube_state],
      ]
    end
               
    def uri(cube_state)
      uri = BASE_URI.dup
      uri.query = URI.encode_www_form(@params + cube_state_params(cube_state))
      uri
    end

    def fetch(cube_state)
      uri = uri(cube_state)
      if r = @cache[uri.to_s]
        r
      else
        @cache[uri.to_s] = image = @fetcher.get(uri)
      end
    end

    def fetch_and_store(cube_state, output)
      image = fetch(cube_state)
      File.open(output, 'wb') { |f| f.write(image) }
    end
    
  end

end
