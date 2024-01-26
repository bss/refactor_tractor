module RefactorTractor
  class Config
    def initialize(
      parallel: true,
      logger: Logger.new(STDOUT),
      dry_run: false,
      rules: [],
      raise_on_error: false,
      file_replacements_dir: nil
    )
      @parallel = !!parallel
      @logger = logger
      @dry_run = !!dry_run
      @raise_on_error = !!raise_on_error
      @rules = rules
      @file_replacements_dir = file_replacements_dir

      rules.each do |r|
        unless r < AstRule || r < FileRule
          raise 'Rule classes must be descendants of RefactorTractor::AstRule or RefactorTractor::FileRule'
        end
      end
    end

    attr_reader :parallel, :logger, :dry_run, :rules, :raise_on_error, :file_replacements_dir
  end
end
