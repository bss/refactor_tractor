module RefactorTractor
  class AstRule < Parser::AST::Processor
    include RuboCop::AST::Traversal

    attr_reader :rewriter, :logger

    def set_opts(rewriter:, logger:)
      @rewriter = rewriter
      @logger = logger
    end

    def create_range(begin_pos, end_pos)
      Parser::Source::Range.new(@rewriter.source_buffer, begin_pos, end_pos)
    end
  end
end
