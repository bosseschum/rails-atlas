# frozen_string_literal: true

module Atlas
  class GraphExporter # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def export_dot(path = 'atlas.dot')
      File.write(path, dot_content)
    end

    private

    def dot_content
      lines = ['digraph Atlas {']

      @graph[:edges].each do |edge|
        lines << <<~DOT
          #{edge[:source]} -> #{edge[:target]} [label="#{edge[:relationship]}"];
        DOT
      end

      lines << '}'

      lines.join("\n")
    end
  end
end
