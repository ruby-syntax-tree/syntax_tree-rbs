# frozen_string_literal: true

require "rbs"
require "syntax_tree"

require_relative "rbs/declarations"
require_relative "rbs/members"
require_relative "rbs/types"
require_relative "rbs/utils"
require_relative "rbs/version"

module SyntaxTree
  module RBS
    # A slight extension to the default PP formatter that keeps track of the
    # source (so that it can be referenced by annotations if they need it) and
    # keeps track of the level of intersections and unions so that parentheses
    # can be forced if necessary.
    class Formatter < PP
      attr_reader :source

      def initialize(source, ...)
        super(...)
        @source = source
        @force_parens = false
      end

      def force_parens
        old_force_parens = @force_parens
        @force_parens = true
        yield
      ensure
        @force_parens = old_force_parens
      end

      def force_parens?
        @force_parens
      end
    end

    # This is the root node of the entire tree. It contains all of the top-level
    # declarations within the file.
    class Root
      attr_reader :declarations

      def initialize(declarations)
        @declarations = declarations
      end

      def format(q)
        separator =
          lambda do
            q.breakable(force: true)
            q.breakable(force: true)
          end

        q.seplist(declarations, separator) { |declaration| declaration.format(q) }
        q.breakable(force: true)
      end

      def pretty_print(q)
        q.group(2, "(root", ")") do
          q.breakable
          q.text("declarations=")
          q.pp(declarations)
        end
      end
    end

    class << self
      def format(source)
        formatter = Formatter.new(source, [])
        parse(source).format(formatter)

        formatter.flush
        formatter.output.join
      end

      def parse(source)
        Root.new(::RBS::Parser.parse_signature(source))
      end

      def read(filepath)
        File.read(filepath)
      end
    end
  end

  register_handler(".rbs", RBS)
end
