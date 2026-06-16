# frozen_string_literal: true

require 'set'

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

    def shortest_path(start_node, end_node)
      queue = [[start_node]]
      visited = Set.new([start_node])

      until queue.empty?
        path = queue.shift
        current = path.last

        return path if current == end_node

        neighbors(current).each do |neighbor|
          next if visited.include?(neighbor)

          visited << neighbor
          queue << (path + [neighbor])
        end
      end

      nil
    end
  end
end
