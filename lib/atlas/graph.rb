# frozen_string_literal: true

module Atlas
  class Graph # rubocop:disable Style/Documentation
    attr_reader :nodes, :edges

    def initialize(nodes:, edges:)
      @nodes = nodes
      @edges = edges
    end

    def neighbors(node)
      connected = []

      edges.each do |edge|
        connected << edge[:target] if edge[:source] == node
        connected << edge[:source] if edge[:target] == node
      end

      connected.uniq
    end

    def degree(node)
      neighbors(node).count
    end
  end
end
