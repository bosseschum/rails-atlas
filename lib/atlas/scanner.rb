module Atlas
  class Scanner
    def initialize(path)
      @path = path
    end

    def model_files
      Dir.glob(File.join(@path, "app/models/**/*.rb"))
    end

    def models
      model_files.map do |file|
        File.basename(file, ".rb")
      end
    end
  end
end
