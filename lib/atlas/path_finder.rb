# frozen_string_literal: true

require 'set'

module Atlas
  class PathFinder # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def find_path(start_node, end_node)
      @graph.shortest_path(start_node, end_node)
    end
  end
end
