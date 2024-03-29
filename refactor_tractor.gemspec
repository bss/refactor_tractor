# frozen_string_literal: true

require_relative "lib/refactor_tractor/version"

Gem::Specification.new do |spec|
  spec.name = "refactor-tractor"
  spec.version = RefactorTractor::VERSION
  spec.authors = ["Bo Stendal Sørensen"]
  spec.email = ["bo@stendal-sorensen.net"]

  spec.summary = "Easily rewrite source code using the Ruby AST"
  spec.description = "Useful during refactorings or upgrades of large code bases."
  spec.homepage = "https://github.com/bss/refactor-tractor"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/bss/refactor-tractor/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rubocop", "~> 1.0"
  spec.add_dependency "rubocop-ast", "~> 1.0"
  spec.add_dependency "parallel", "~> 1.0"
  spec.add_dependency "thor", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
