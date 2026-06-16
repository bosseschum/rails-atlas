# frozen_string_literal: true

require 'json'
require 'active_support/inflector'
require_relative 'graph'

module Atlas
  class GraphBuilder # rubocop:disable Style/Documentation
    def initialize(scanner)
      @scanner = scanner
    end

    def build # rubocop:disable Metrics/MethodLength
      nodes = []
      edges = []

      @scanner.model_files.each do |file|
        model_name = File.basename(file, '.rb')

        next if model_name == "application_record"

        nodes << {
          id: model_name,
          type: 'model',
        }

        extractor = AssociationExtractor.new(file)

        extractor.extract.each do |association|
          association[:target].to_s.singularize

          edges << {
            source: model_name,
            target: association[:target],
            relationship: association[:type],
            association_name: association[:association_name]
          }
        end
      end

      Graph.new(nodes: nodes.uniq, edges: edges)
    end
  end
end
