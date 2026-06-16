# frozen_string_literal: true

module Atlas
  class Neighbors # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def find(model_name)
      @graph.connections_for(model_name)
    end
  end
end
