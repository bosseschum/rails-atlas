require "set"

module Atlas
  class PathFinder
    def initialize(graph)
      @graph = graph
    end

    def find_path(start_node, end_node)
      queue = [[start_node]]
      visited = Set.new([start_node])

      until queue.empty?
        path = queue.shift
        current = path.last
        return path if current == end_node

        neighbors(current).each do |neighbor|
          next if visited.include?(neighbor)

          visited.add(neighbor)
          queue << (path + [neighbor])
        end
      end

      nil
    end

    private

    def neighbors(node)
      @graph[:edges]
      .select { |edge| edge[:source] == node }
      .map { |edge| edge[:target] }
    end
  end
end
