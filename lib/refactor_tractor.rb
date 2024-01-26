# frozen_string_literal: true

require 'rubocop'
require 'rubocop-ast'
require 'logger'
require 'parallel'
require 'pathname'
require 'thor'

require_relative "refactor_tractor/version"
require_relative "refactor_tractor/config"
require_relative "refactor_tractor/file_processor"
require_relative "refactor_tractor/prefix_logger"
require_relative "refactor_tractor/processor"
require_relative "refactor_tractor/ast_rule"
require_relative "refactor_tractor/file_rule"
require_relative "refactor_tractor/cli"

module RefactorTractor
  class Error < StandardError; end
  # Your code goes here...
end
