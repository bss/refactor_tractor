
module RefactorTractor
  class Cli < Thor
    option :help

    option :dry, type: :boolean, default: false
    option :parallel, type: :boolean, default: true
    option :log_level, type: :string, default: 'info', enum: ['error', 'warn', 'info', 'debug']
    option :raise_on_error, type: :boolean, default: true
    option :only, type: :array, default: []
    option :except, type: :array, default: []

    desc "<UPGRADE> [<PATHS>]...", "run the specified upgrades for the given paths"
    def execute(upgrade_path, *paths)
      if options[:help]
        self.class.command_help(Thor::Base.shell.new, 'execute')
        return
      end

      logger = Logger.new(STDOUT)
      logger.level = log_level_from_options

      base_path = Pathname.new(File.absolute_path(upgrade_path))
      rules = load_rules(base_path)
      rules = rules.select { |kls| options[:only].empty? || options[:only].include?(kls.name) }
      rules = rules.reject { |kls| options[:except].include?(kls.name) }

      processor = RefactorTractor::Processor.new(
        RefactorTractor::Config.new(
          parallel: options[:parallel],
          logger: logger,
          dry_run: options[:dry],
          raise_on_error: options[:raise_on_error],
          file_replacements_dir: base_path.join('file_replacements'),
          rules: rules,
        )
      )

      if paths.empty?
        paths = ['.']
      end
      processor.run(paths)
    end

    def self.exit_on_failure?
      false
    end

    no_commands do
      def log_level_from_options
        case options[:log_level]
        when 'error'
          Logger::ERROR
        when 'warn'
          Logger::WARN
        when 'info'
          Logger::INFO
        when 'debug'
          Logger::DEBUG
        else
          raise "Unknown log level #{options[:log_level]}"
        end
      end

      def load_rules(base_path)
        rules_path = base_path.join('rules')
        rules_files = rules_path.glob('*.rb').sort
        # Load up all the rules
        rules_files.each { |p| require(p) }

        rules_per_file = files_to_rules_mapping(rules_path)

        rules_files.flat_map { |p| rules_per_file[p.to_s] }.compact
      end

      def source_location_of_class(rules_path, kls)
        source_locations = kls.instance_methods.map { |m| kls.instance_method(m).source_location }.compact
        source_locations = source_locations.sort_by(&:last).reverse
        source_locations.find { |sl| sl.first.start_with?(rules_path.to_s) }
      end

      def files_to_rules_mapping(rules_path)
        rule_classes = ObjectSpace.each_object(Class).select { |kls| kls < RefactorTractor::AstRule || kls < RefactorTractor::FileRule }
        rules_per_file = rule_classes.each_with_object({}) do |kls, hsh|
          source_location = source_location_of_class(rules_path, kls)

          hsh[source_location.first] ||= []
          hsh[source_location.first] << [kls, source_location.last]
        end

        rules_per_file.transform_values do |rules_location|
          rules_location.sort_by(&:last).map(&:first)
        end
      end
    end
  end
end
