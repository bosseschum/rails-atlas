# frozen_string_literal: true

require 'json'
require 'active_support/inflector'
require_relative 'graph'

module Atlas
  class GraphBuilder
    def initialize(scanner)
      @scanner = scanner
    end

    def build
      model_ids = build_model_ids

      nodes = model_ids.values.uniq.map { |id| { id: id, type: 'model' } }
      edges = build_edges(model_ids)

      Graph.new(nodes: nodes, edges: edges)
    end

    private

    # file path => fully-qualified model id, e.g. "app/models/treasurer/request.rb" => "Treasurer::Request"
    def build_model_ids
      @scanner.model_files.each_with_object({}) do |file, ids|
        model_id = @scanner.model_name_for(file)
        next if model_id == 'ApplicationRecord'

        ids[file] = model_id
      end
    end

    def build_edges(model_ids)
      known_ids = model_ids.values

      model_ids.each_with_object([]) do |(file, model_id), edges|
        AssociationExtractor.new(file).extract.each do |association|
          edges << {
            source: model_id,
            target: resolve_target(model_id, association[:target], known_ids),
            relationship: association[:type],
            association_name: association[:association_name]
          }
        end
      end
    end

    # Mirrors ActiveRecord::Inheritance#compute_type: try the target name scoped
    # under progressively shorter slices of the declaring model's own namespace
    # before falling back to the bare (top-level) name. This is what lets
    # `Treasurer::Request` -> `has_many :line_items` resolve to
    # `Treasurer::LineItem` instead of a top-level `LineItem` when both exist.
    def resolve_target(declaring_id, type_name, known_ids)
      namespace_candidates(declaring_id, type_name).find { |candidate| known_ids.include?(candidate) } || type_name
    end

    def namespace_candidates(declaring_id, type_name)
      parts = declaring_id.split('::')
      parts.pop

      candidates = []

      until parts.empty?
        candidates << "#{parts.join('::')}::#{type_name}"
        parts.pop
      end

      candidates << type_name
    end
  end
end
