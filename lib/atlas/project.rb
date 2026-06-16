# frozen_string_literal: true

module Atlas
  class Project # rubocop:disable Style/Documentation
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def scanner
      @scanner ||= Scanner.new(path)
    end

    def graph
      @graph ||= GraphBuilder.new(scanner).build
    end

    def inspector
      @inspector ||= Inspector.new(graph)
    end

    def path_finder
      @path_finder ||= PathFinder.new(graph)
    end

    def neighbors
      @neighbors ||= Neighbors.new(graph)
    end

    def hotspots
      @hotspots ||= Hotspots.new(graph)
    end

    def smells
      @smells ||= Smells.new(graph)
    end
  end
end
