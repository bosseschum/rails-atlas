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
      @graph.node_ids.select do |node_id|
        @graph.degree(node_id) <= threshold # rubocop:disable Lint/Void
        next if node_id == 'application_record'
      end
    end
  end
end
