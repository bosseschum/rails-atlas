require "prism"
require "active_support/inflector"

module Atlas
  class AssociationExtractor
    ASSOCIATIONS = %w[
      belongs_to
      has_many
      has_one
      has_and_belongs_to_many
    ].freeze

    def initialize(file)
      @file = file
    end

    def extract
      source = File.read(@file)

      result = Prism.parse(source)

      associations = []

      walk(result.value, associations)

      associations
    end

    private

    def walk(node, associations)
      return unless node.respond_to?(:child_nodes)

      if node.is_a?(Prism::CallNode)
        method_name = node.name.to_s

        if ASSOCIATIONS.include?(method_name)
          target = extract_target(node)
          associations << {
            type: method_name,
            association_name: target,
            target: target.to_s.singularize
          }
        end
      end

      node.child_nodes.each do |child|
        walk(child, associations)
      end
    end

    def extract_target(node)
      arg = node.arguments&.arguments&.first

      return unless arg

      if arg.respond_to?(:unescaped)
        arg.unescaped.to_s
      elsif arg.respond_to?(:value)
        arg.value.to_s
      end
    end
  end
end
