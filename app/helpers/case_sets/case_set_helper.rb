require 'case_pattern/case_pattern'

module CaseSets
  # Helpers included for all case sets.
  module CaseSetHelper
    include CasePattern::CasePatternDsl

      def match?(casee)
        pattern.match?(casee)
      end

      def eql?(other)
        self.class.equal?(other.class) && pattern == other.pattern
      end

      alias == eql?

      def hash
        [self.class, pattern].hash
      end

      def pattern
        raise NotImplementedError
      end
    end
end
