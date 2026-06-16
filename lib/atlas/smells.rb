# frozen_string_literal: true

module Atlas
  class Smells # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def god_models(threshold: 10)
      counts = Hash.new(0)

      @graph.edges.each do |edge|
        counts[edge[:source]] += 1
        counts[edge[:target]] += 1
      end

      counts.select { |_, count| count >= threshold }
    end

    def orphan_models(threshold: 1)
      counts = Hash.new(0)

      @graph.edges.each do |edge|
        counts[edge[:source]] += 1
        counts[edge[:target]] += 1
      end

      counts.select { |_, count| count < threshold }
    end
  end
end
