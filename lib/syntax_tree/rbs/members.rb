# frozen_string_literal: true

module SyntaxTree
  module RBS
    # Prints out an attr_* meta method, which looks like:
    # attr_accessor foo: Foo
    # attr_reader foo: Foo
    # attr_writer foo: Foo
    class Attribute
      attr_reader :type, :node

      def initialize(type, node)
        @type = type
        @node = node
      end

      def format(q)
        q.group do
          if node.respond_to?(:visibility) && node.visibility
            q.text("#{node.visibility} ")
          end

          q.text("attr_#{type} ")
          q.text("self.") if node.kind == :singleton
          q.text(node.name)

          if node.ivar_name == false
            q.text("()")
          elsif node.ivar_name
            q.text("(")
            q.text(node.ivar_name)
            q.text(")")
          end

          q.text(": ")
          node.type.format(q)
        end
      end

      def pretty_print(q)
        if node.kind == :singleton
          q.breakable
          q.text("singleton")
        end

        q.breakable
        q.text("name=")
        q.pp(node.name)

        if node.respond_to?(:visibility) && node.visibility
          q.breakable
          q.text("visibility=")
          q.pp(node.visibility)
        end

        unless node.ivar_name.nil?
          q.breakable
          q.text("ivar_name=")
          q.pp(node.ivar_name)
        end

        q.breakable
        q.text("type=")
        q.pp(node.type)
      end
    end
  end
end

module RBS
  module AST
    module Members
      class Alias
        # Prints out an alias within a declaration, which looks like:
        # alias foo bar
        # alias self.foo self.bar
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          if kind == :singleton
            q.text("alias self.")
            q.text(new_name)
            q.text(" self.")
            q.text(old_name)
          else
            q.text("alias ")
            q.text(new_name)
            q.text(" ")
            q.text(old_name)
          end
        end

        def pretty_print(q)
          q.group(2, "(alias", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)

            if kind == :singleton
              q.breakable
              q.text("singleton")
            end

            q.breakable
            q.text("new_name=")
            q.pp(new_name)

            q.breakable
            q.text("old_name=")
            q.pp(old_name)
          end
        end
      end

      class AttrAccessor
        # Prints out an attr_accessor meta method, which looks like:
        # attr_accessor foo: Foo
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)
          SyntaxTree::RBS::Attribute.new(:accessor, self).format(q)
        end

        def pretty_print(q)
          q.group(2, "(attr-accessor", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)
            q.pp(SyntaxTree::RBS::Attribute.new(:accessor, self))
          end
        end
      end

      class AttrReader
        # Prints out an attr_reader meta method, which looks like:
        # attr_reader foo: Foo
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)
          SyntaxTree::RBS::Attribute.new(:reader, self).format(q)
        end

        def pretty_print(q)
          q.group(2, "(attr-reader", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)
            q.pp(SyntaxTree::RBS::Attribute.new(:reader, self))
          end
        end
      end

      class AttrWriter
        # Prints out an attr_writer meta method, which looks like:
        # attr_writer foo: Foo
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)
          SyntaxTree::RBS::Attribute.new(:writer, self).format(q)
        end

        def pretty_print(q)
          q.group(2, "(attr-writer", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)
            q.pp(SyntaxTree::RBS::Attribute.new(:writer, self))
          end
        end
      end

      class ClassInstanceVariable
        # Prints out a class instance variable member, which looks like:
        # self.@foo: String
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)

          q.group do
            q.text("self.")
            q.text(name)
            q.text(": ")
            type.format(q)
          end
        end

        def pretty_print(q)
          q.group(2, "(class-instance-variable", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)

            q.breakable
            q.text("name=")
            q.pp(name)
          end
        end
      end

      class ClassVariable
        # Prints out a class variable member, which looks like:
        # @@foo: String
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)

          q.group do
            q.text(name)
            q.text(": ")
            type.format(q)
          end
        end

        def pretty_print(q)
          q.group(2, "(class-variable", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)

            q.breakable
            q.text("name=")
            q.pp(name)
          end
        end
      end

      class Extend
        # Prints out an extend, which looks like:
        # extend Foo
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          q.group do
            q.text("extend ")
            SyntaxTree::RBS::NameAndArgs.new(self).format(q)
          end
        end

        def pretty_print(q)
          q.group(2, "(extend", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)
            q.pp(SyntaxTree::RBS::NameAndArgs.new(self))
          end
        end
      end

      class Include
        # Prints out an include, which looks like:
        # include Foo
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          q.group do
            q.text("include ")
            SyntaxTree::RBS::NameAndArgs.new(self).format(q)
          end
        end

        def pretty_print(q)
          q.group(2, "(include", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)
            q.pp(SyntaxTree::RBS::NameAndArgs.new(self))
          end
        end
      end

      class InstanceVariable
        # Prints out an instance variable member, which looks like:
        # @foo: String
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)

          q.group do
            q.text(name)
            q.text(": ")
            type.format(q)
          end
        end

        def pretty_print(q)
          q.group(2, "(instance-variable", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)

            q.breakable
            q.text("name=")
            q.pp(name)
          end
        end
      end

      class MethodDefinition
        # Prints out a method definition, which looks like:
        # def t: (T t) -> void
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          q.group do
            if respond_to?(:visibility) && visibility
              q.text("#{visibility} ")
            end

            q.text("def ")

            if kind == :singleton
              q.text("self.")
            elsif kind == :singleton_instance
              q.text("self?.")
            end

            q.text(Parser::KEYWORDS.include?(name.to_s) ? "`#{name}`" : name)
            q.text(":")

            if types.length == 1 && !overload?
              q.text(" ")
              SyntaxTree::RBS::MethodSignature.new(types.first).format(q)
            else
              separator =
                lambda do
                  q.breakable
                  q.text("| ")
                end

              q.group do
                q.indent do
                  q.breakable
                  q.seplist(types, separator) do |type|
                    SyntaxTree::RBS::MethodSignature.new(type).format(q)
                  end

                  if overload?
                    separator.call
                    q.text("...")
                  end
                end
              end
            end
          end
        end

        def pretty_print(q)
          q.group(2, "(method-definition", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)

            q.breakable
            q.text("kind=")
            q.pp(kind)

            q.breakable
            q.text("name=")
            q.pp(name)

            if respond_to?(:visibility) && visibility
              q.breakable
              q.text("visibility=")
              q.pp(visibility)
            end

            if overload?
              q.breakable
              q.text("overload")
            end

            q.breakable
            q.text("types=")
            q.group(2, "[", "]") do
              q.breakable("")
              q.seplist(types) do |type|
                q.pp(SyntaxTree::RBS::MethodSignature.new(type))
              end
              q.breakable("")
            end
          end
        end
      end

      class Prepend
        # Prints out a prepend, which looks like:
        # prepend Foo
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          q.group do
            q.text("prepend ")
            SyntaxTree::RBS::NameAndArgs.new(self).format(q)
          end
        end

        def pretty_print(q)
          q.group(2, "(prepend", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)
            q.pp(SyntaxTree::RBS::NameAndArgs.new(self))
          end
        end
      end

      class Private
        # Prints out a private declaration, which looks like:
        # private
        def format(q)
          q.text("private")
        end

        def pretty_print(q)
          q.text("(private)")
        end
      end

      class Public
        # Prints out a public declaration, which looks like:
        # public
        def format(q)
          q.text("public")
        end

        def pretty_print(q)
          q.text("(public)")
        end
      end
    end
  end
end
