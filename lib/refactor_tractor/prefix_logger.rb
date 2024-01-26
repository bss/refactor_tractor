module RefactorTractor
  class PrefixLogger
    def initialize(logger, prefix)
      @logger = logger
      @prefix = prefix
    end

    def prefix_message(msg)
      "#{@prefix} #{msg}"
    end

    def debug(msg)
      @logger.debug(prefix_message(msg))
    end

    def info(msg)
      @logger.info(prefix_message(msg))
    end

    def warn(msg)
      @logger.warn(prefix_message(msg))
    end

    def error(msg)
      @logger.error(prefix_message(msg))
    end

    def fatal(msg)
      @logger.fatal(prefix_message(msg))
    end
  end
end
