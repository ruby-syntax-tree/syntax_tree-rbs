# frozen_string_literal: true

require "prettier_print"
require "rbs"
require "syntax_tree"

module SyntaxTree
  module RBS
    # This is the parent class of any of the visitors that we define in this
    # module. It is used to walk through the tree.
    class Visitor
      def visit(node)
        node&.accept(self)
      end
    end

    # A slight extension to the default PrettierPrint formatter that keeps track
    # of the source (so that it can be referenced by annotations if they need
    # it) and keeps track of the level of intersections and unions so that
    # parentheses can be forced if necessary.
    class Formatter < PrettierPrint
      attr_reader :source

      def initialize(source, *rest)
        super(*rest)
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

    class << self
      def format(source, maxwidth = 80)
        formatter = Formatter.new(source, [], maxwidth)
        parse(source).format(formatter)

        formatter.flush
        formatter.output.join
      end

      def parse(source)
        _, _, declarations = ::RBS::Parser.parse_signature(source)
        Root.new(declarations)
      end

      def read(filepath)
        File.read(filepath)
      end
    end
  end

  register_handler(".rbs", RBS)
end

require_relative "rbs/shims"
require_relative "rbs/entrypoints"
require_relative "rbs/format"
require_relative "rbs/pretty_print"
require_relative "rbs/version"
