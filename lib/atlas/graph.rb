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
      connections_for(node).size
    end

    def node_data
      nodes.map do |node|
        {
          id: node[:id],
          degree: degree(node[:id])
        }
      end
    end

    def shortest_path(start_node, end_node) # rubocop:disable Metrics/MethodLength
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

    def reachable_from(start_node) # rubocop:disable Metrics/MethodLength
      visited = Set.new
      queue = [start_node]

      until queue.empty?
        current = queue.shift
        next if visited.include?(current)

        visited << current

        neighbors(current).each do |neighbor|
          queue << neighbor
        end
      end

      visited.to_a - [start_node]
    end

    def connections_for(node) # rubocop:disable Metrics/MethodLength
      connections = []

      edges.each do |edge|
        if edge[:source] == node
          connections << {
            model: edge[:target],
            relationship: edge[:relationship],
            association_name: edge[:association_name],
            direction: :outgoing
          }
        end

        next unless edge[:target] == node

        connections << {
          model: edge[:source],
          relationship: edge[:relationship],
          association_name: edge[:association_name],
          direction: :incoming
        }
      end

      connections
    end

    def outgoing_connections(node)
      connections_for(node).select { |c| c[:direction] == :outgoing }
    end

    def incoming_connections(node)
      connections_for(node).select { |c| c[:direction] == :incoming }
    end

    def node_ids
      nodes.map { |node| node[:id] }
    end

    def metrics_for(node)
      {
        degree: degree(node),
        impact: reachable_from(node).size,
        incoming: incoming_connections(node).size,
        outgoing: outgoing_connections(node).size,
        hotspot: degree(node) > 10,
        orphan: degree(node).zero?
      }
    end
  end
end
