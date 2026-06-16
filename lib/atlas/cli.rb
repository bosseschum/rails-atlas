# frozen_string_literal: true

require 'thor'
require 'json'
require_relative 'project'
require_relative 'scanner'
require_relative 'association_extractor'
require_relative 'graph_builder'
require_relative 'stats'
require_relative 'graph_exporter'
require_relative 'inspector'
require_relative 'path_finder'
require_relative 'neighbors'

module Atlas
  class CLI < Thor # rubocop:disable Style/Documentation
    desc 'scan PATH', 'Scan a Rails application'

    def scan(path)
      project = Project.new(path)

      File.write(
        'atlas.json',
        JSON.pretty_generate(project.graph)
      )

      puts 'Scan complete. Atlas graph saved to atlas.json'
    end

    desc 'stats PATH', 'Show graph statistics'

    def stats(path)
      project = Project.new(path)

      Stats.new(project.graph).print
    end

    desc 'graph PATH', 'Generate graph files'

    def graph(path)
      project = Project.new(path)

      GraphExporter.new(project.graph).export_dot

      puts 'Generate atlas.dot'
    end

    desc 'model PATH MODEL', 'Inspect a model'

    def model(path, model) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      project = Project.new(path)

      result = project.inspector.inspect(model)

      puts
      puts "Model: #{model}"
      puts

      puts 'Outgoing Associations:'
      puts '----------------------'

      result[:outgoing].each do |edge|
        puts "#{edge[:relationship]} #{edge[:association_name]}"
      end

      puts
      puts 'Incoming Associations:'
      puts '----------------------'

      result[:incoming].each do |edge|
        puts "#{edge[:source]} #{edge[:relationship]} #{edge[:association_name]}"
      end
    end

    desc 'path PATH START END', 'Find path between two models'

    def path(path, start, end_node) # rubocop:disable Metrics/MethodLength
      project = Project.new(path)
      result = project.path_finder.find_path(start, end_node)

      if result.nil?
        puts 'No path found'
        return
      end

      puts
      result.each_with_index do |node, index|
        puts node

        puts ' ↓' unless index == result.length - 1
      end
    end

    desc 'neighbors MODEL', 'Show directly connected neighbors'

    def neighbors(path, model) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      project = Project.new(path)
      neighbors = project.neighbors.find(model)

      puts
      puts "Model: #{model}"
      puts
      puts 'Directly Connected Models'
      puts '-------------------------'

      neighbors.each do |neighbor|
        if neighbor[:direction] == :outgoing
          puts "[OUT] #{neighbor[:relationship]} #{neighbor[:association_name]} → #{neighbor[:model]}"
        else
          puts "[IN] #{neighbor[:model]} #{neighbor[:relationship]} #{neighbor[:association_name]}"
        end
      end
    end
  end
end
