# frozen_string_literal: true

module RBS
  class TypeName
    def format(q)
      q.text(to_s)
    end

    def pretty_print(q)
      q.group(2, "(type-name", ")") do
        q.breakable
        q.pp(to_s)
      end
    end
  end

  module Types
    class Alias
      def format(q)
        name.format(q)
      end

      def pretty_print(q)
        q.group(2, "(alias", ")") do
          q.breakable
          q.text("name=")
          q.pp(name)
        end
      end
    end

    module Bases
      class Base
        def format(q)
          q.text(to_s)
        end

        def pretty_print(q)
          q.text("(#{self.class.name.downcase})")
        end
      end
    end

    class ClassInstance
      def format(q)
        SyntaxTree::RBS::NameAndArgs.new(self).format(q)
      end
    
      def pretty_print(q)
        q.group(2, "(class-instance", ")") do
          q.pp(SyntaxTree::RBS::NameAndArgs.new(self))
        end
      end
    end

    class ClassSingleton
      def format(q)
        q.text("singleton(")
        name.format(q)
        q.text(")")
      end

      def pretty_print(q)
        q.group(2, "(class-singleton", ")") do
          q.breakable
          q.text("name=")
          q.pp(name)
        end
      end
    end

    class Function
      class Param
        def format(q)
          type.format(q)

          if name
            q.text(" ")

            if Parser::KEYWORDS.include?(name.to_s)
              q.text("`#{name}`")
            else
              q.text(name)
            end
          end
        end

        def pretty_print(q)
          q.group(2, "(param", ")") do
            q.breakable
            q.text("type=")
            q.pp(type)

            if name
              q.breakable
              q.text("name=")
              q.pp(name)
            end
          end
        end
      end
    end

    class Interface
      def format(q)
        SyntaxTree::RBS::NameAndArgs.new(self).format(q)
      end

      def pretty_print(q)
        q.group(2, "(interface", ")") do
          q.pp(SyntaxTree::RBS::NameAndArgs.new(self))
        end
      end
    end

    class Intersection
      def format(q)
        separator =
          lambda do
            q.breakable
            q.text("& ")
          end

        q.text("(") if q.force_parens?
        q.group do
          q.force_parens { q.seplist(types, separator) { |type| type.format(q) } }
        end
        q.text(")") if q.force_parens?
      end

      def pretty_print(q)
        q.group(2, "(intersection", ")") do
          q.breakable
          q.text("types=")
          q.pp(types)
        end
      end
    end

    class Literal
      def format(q)
        unless literal.is_a?(String)
          q.text(literal.inspect)
          return
        end

        # We're going to go straight to the source here, as if we don't then
        # we're going to end up with the result of String#inspect, which does
        # weird things to escape sequences.
        source = q.source[location.range]
        quote = source.include?("\\") ? source[0] : "\""
        source = SyntaxTree::Quotes.normalize(source[1..-2], quote)

        q.text(quote)
        q.seplist(source.split(/\r?\n/), -> { q.breakable(force: true) }) do |line|
          q.text(line)
        end
        q.text(quote)
      end

      def pretty_print(q)
        q.group(2, "(literal", ")") do
          q.breakable
          q.pp(literal)
        end
      end
    end

    class Optional
      def format(q)
        q.force_parens { type.format(q) }
        q.text("?")
      end

      def pretty_print(q)
        q.group(2, "(optional", ")") do
          q.breakable
          q.pp(type)
        end
      end
    end

    class Proc
      def format(q)
        q.text("^")
        SyntaxTree::RBS::MethodSignature.new(self).format(q)
      end

      def pretty_print(q)
        q.group(2, "(proc", ")") do
          q.pp(SyntaxTree::RBS::MethodSignature.new(self))
        end
      end
    end

    class Record
      def format(q)
        separator =
          lambda do
            q.text(",")
            q.breakable
          end

        q.group do
          q.text("{")
          q.indent do
            q.breakable
            q.seplist(fields, separator, :each_pair) do |key, type|
              if key.is_a?(Symbol) && key.match?(/\A[A-Za-z_][A-Za-z_]*\z/)
                q.text("#{key}: ")
              else
                q.text("#{key.inspect} => ")
              end

              type.format(q)
            end
          end
          q.breakable
          q.text("}")
        end
      end

      def pretty_print(q)
        q.group(2, "(record", ")") do
          q.breakable
          q.text("fields=")
          q.pp(fields)
        end
      end
    end

    class Tuple
      def format(q)
        # If we don't have any sub types, we explicitly need the space in
        # between the brackets to not confuse the parser.
        if types.empty?
          q.text("[ ]")
          return
        end

        q.group do
          q.text("[")
          q.seplist(types, -> { q.text(", ") }) { |type| type.format(q) }
          q.text("]")
        end
      end

      def pretty_print(q)
        q.group(2, "(tuple", ")") do
          q.breakable
          q.text("types=")
          q.pp(types)
        end
      end
    end

    class Union
      def format(q)
        separator =
          lambda do
            q.breakable
            q.text("| ")
          end

        q.text("(") if q.force_parens?
        q.group { q.seplist(types, separator) { |type| type.format(q) } }
        q.text(")") if q.force_parens?
      end

      def pretty_print(q)
        q.group(2, "(union", ")") do
          q.breakable
          q.text("types=")
          q.pp(types)
        end
      end
    end

    class Variable
      def format(q)
        q.text(name)
      end

      def pretty_print(q)
        q.group(2, "(variable", ")") do
          q.breakable
          q.text("name=")
          q.pp(name)
        end
      end
    end
  end
end
