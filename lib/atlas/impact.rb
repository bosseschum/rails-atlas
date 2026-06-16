# frozen_string_literal: true

module Atlas
  class Impact # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def analyze(model)
      @graph.reachable_from(model)
    end
  end
end
