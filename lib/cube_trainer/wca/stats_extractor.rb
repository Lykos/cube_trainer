# frozen_string_literal: true

module CubeTrainer
  module WCA
    # Class that extracts stats from a parsed WCA export.
    class StatsExtractor
      def initialize(export_parser)
        @export_parser = export_parser
      end

      def nemesis?(badguy, victim)
        badranks = @export_parser.ranks[badguy]
        victimranks = @export_parser.ranks[victim]
        victimranks.all? do |k, v|
          badranks&.key?(k) && badranks[k][:worldrank] < v[:worldrank]
        end
      end

      def nemeses(wcaid)
        badguys = []
        @export_parser.persons.each_key do |id|
          next if id == wcaid

          badguys.push(id) if nemesis?(id, wcaid)
        end
        badguys
      end
    end
  end
end
