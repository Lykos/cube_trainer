# frozen_string_literal: true

module CubeTrainer
  class WCAResult
    def initialize(type, time_centis, attempted, solved, number)
      @type = type
      @time_centis = time_centis
      @attempted = attempted
      @solved = solved
      @number = number
    end

    DNF = new(:DNF, nil, nil, nil, nil)
    DNS = new(:DNS, nil, nil, nil, nil)

    attr_reader :type, :time_centis, :attempted, :solved, :number

    def self.special_value(result_int)
      case result_int
      when -1 then DNF
      when -2 then DNS
      end
    end

    def self.multi(result_int)
      if s = special_value(result_int) then return s end

      multi_type = case result_int / 1_000_000_000
                   when 1 then :old
                   when 0 then :new
                   else
                     raise ArgumentError, "Can't handle multi result #{result_int}."
                   end
      if multi_type == :new
        missed = result_int % 100
        time_centis = (result_int / 100) % 100_000 * 100
        time_centis = nil if time_centis == 99_999
        d = result_int / 10_000_000 % 100
        difference = 99 - d
        solved = difference + missed
        attempted = solved + missed
        new(:success, time_centis, attempted, solved, nil)
      elsif multi_type == :old
        time_centis = result_int % 100_000 * 100
        time_centis = nil if time_centis == 99_999
        attempted = result_int / 100_000 % 100
        s = result_int / 10_000_000 % 100
        solved = 99 - s
        new(:success, time_centis, attempted, solved, nil)
      else
        raise
      end
    end

    def self.number(result_int)
      if s = special_value(result_int) then return s end

      new(:success, nil, nil, nil, result_int)
    end

    def self.time(result_int)
      if s = special_value(result_int) then return s end

      new(:success, result_int, nil, nil, nil)
    end
  end
end
