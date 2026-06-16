# frozen_string_literal: true

module Atlas
  class Hotspots # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def top(limit = 10)
      @graph.nodes
            .map { |node| [node, @graph.degree(node)] }
            .sort_by { |_, degree| -degree }
            .first(limit)
    end
  end
end
