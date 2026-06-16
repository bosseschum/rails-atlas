# frozen_string_literal: true

module Atlas
  class Neighbors # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def find(model_name) # rubocop:disable Metrics/MethodLength
      connected = []

      @graph.edges.each do |edge|
        next unless edge[:source] == model_name

        connected << {
          model: edge[:target],
          relationship: edge[:relationship],
          association_name: edge[:association_name],
          direction: :outgoing
        }

        next unless edge[:target] == model_name

        connected << {
          model: edge[:source],
          relationship: edge[:relationship],
          association_name: edge[:association_name],
          direction: :incoming
        }
      end

      connected.uniq { |c| c[:model] }
    end
  end
end
