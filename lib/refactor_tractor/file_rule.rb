module RefactorTractor
  class FileRule
    attr_reader :path, :logger

    def set_opts(path:, logger:)
      @path = path
      @logger = logger
    end
  end
end
