# frozen_string_literal: true

module Atlas
  class Hotspots # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def top(limit = 10)
      counts = Hash.new(0)

      @graph[:edges].each do |edge|
        counts[edge[:source]] += 1
        counts[edge[:target]] += 1
      end

      counts
        .sort_by { |_, count| -count }
        .first(limit)
    end
  end
end
