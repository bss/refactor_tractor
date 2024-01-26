module RefactorTractor
  class Processor
    extend Forwardable

    attr_reader :config
    def_delegator :config, :logger

    def initialize(config)
      @config = config

      RuboCop::AST::Builder.emit_lambda = true
    end

    def run(paths)
      files = files_to_process(paths)
      run_file_replacements if config.file_replacements_dir && all_files_in_root_of_rails_app?(files)
      if config.parallel
        logger.info "Running AST processor in parallel"
        Parallel.each(files, in_processes: 8) do |file|
          FileProccessor.new(file, config).process!
        end
      else
        logger.info "Running AST processor sequentially"
        files.each do |file|
          FileProccessor.new(file, config).process!
        end
      end
    end

    def run_file_replacements
      Pathname.glob(config.file_replacements_dir.join('**', '*')).select(&:file?).each do |path|
        original_file_path = path.relative_path_from(config.file_replacements_dir)
        new_content = File.read(path)
        if !original_file_path.exist? || File.read(original_file_path) != new_content
          logger.info "Replacing #{original_file_path} with #{path}"
          File.write(original_file_path, new_content)
        end
      end
    end

    def all_files_in_root_of_rails_app?(files)
      longest_prefix = longest_common_prefix(files)
      files.include?(File.join(longest_prefix, 'config', 'application.rb'))
    end

    def longest_common_prefix(files)
      shortest_path = files.map { |f| f.split('/') }.min_by(&:size)
      prefixes_to_try = (shortest_path.size-1).times.map do |i|
        p = shortest_path[0..i]
        p == [''] ? '/' : p.join('/')
      end
      prefixes_to_try.reverse.find { |p| files.all? { |f| f.start_with?(p) } }
    end

    def run_for(file)
      FileProccessor.new(file, config).process!
    end

    def files_to_process(paths)
      paths.flat_map do |p|
        files_for_path(Pathname.new(p))
      end.uniq.compact.map(&:to_s)
    end

    def files_for_path(path)
      path = path.expand_path
      if path.file?
        [path.to_s]
      elsif path.directory?
        path.glob('**/*.rb')
      else
        raise "Path #{path} does not exist"
      end
    end
  end
end
