# frozen_string_literal: true

module Atlas
  class Hotspots # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def top(limit = 10)
      @graph.node_ids
            .map { |node_id| [node_id, @graph.degree(node_id)] }
            .sort_by { |_, degree| -degree }
            .first(limit)
    end
  end
end
