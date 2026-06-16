module Atlas
  class Project
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
  end
end
