module RefactorTractor
  class FileProccessor
    attr_reader :path, :logger, :config

    def initialize(path, config)
      @path = path
      @logger = PrefixLogger.new(config.logger, "[#{path}]")
      @config = config
    end

    def process!
      return unless File.exist?(path)

      code = File.read(path)
      logger.debug "Processing"
      new_code = process_rules(code)
      if code != new_code
        if config.dry_run
          logger.info "Content to write, skipping due to dry-run"
        else
          File.write(path, new_code)
          logger.info "Content written"
        end
      end
    rescue => e
      logger.error "Error processing file: #{e.message}"
      raise e if config.raise_on_error
    end

    def process_rules(code)
      config.rules.each do |rule_class|
        code = process_single_rule(rule_class, code)
      end
      code
    end

    def process_single_rule(rule_class, code)
      prefixed_logger = PrefixLogger.new(logger, "[#{rule_class.name.to_s}]")
      if rule_class < AstRule
        process_ast_rule(rule_class, code, prefixed_logger)
      elsif rule_class < FileRule
        process_file_rule(rule_class, code, prefixed_logger)
      else
        raise "Unable to handle rule class: #{rule_class}"
      end
    end

    def process_ast_rule(rule_class, code, prefixed_logger)
      source = RuboCop::ProcessedSource.new(code, 2.7)
      rewriter = Parser::Source::TreeRewriter.new(source.buffer)
      rule = rule_class.new.tap do |r|
        r.set_opts(rewriter: rewriter, logger: prefixed_logger)
      end
      if source.ast.nil?
        logger.debug "No AST present"
        return code
      end
      source.ast.each_node { |n| rule.process(n) }
      rewriter.process
    end

    def process_file_rule(rule_class, code, prefixed_logger)
      rule = rule_class.new.tap do |r|
        r.set_opts(path: path, logger: prefixed_logger)
      end
      rule.process(code)
    end
  end
end
