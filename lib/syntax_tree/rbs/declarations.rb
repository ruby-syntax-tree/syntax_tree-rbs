# frozen_string_literal: true

module RBS
  module AST
    module Declarations
      class Alias
        # Prints out a type alias, which is a declaration that looks like:
        # type foo = String
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          q.group do
            q.text("type ")
            name.format(q)
            q.text(" =")
            q.group do
              q.indent do
                q.breakable
                type.format(q)
              end
            end
          end
        end

        def pretty_print(q)
          q.group(2, "(constant", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)

            q.breakable
            q.text("name=")
            q.pp(name)

            q.breakable
            q.text("type=")
            q.pp(type)
          end
        end
      end

      class Class
        # Prints out a class declarations, which looks like:
        # class Foo end
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          q.group do
            q.text("class ")
            SyntaxTree::RBS::NameAndTypeParams.new(self).format(q)

            if super_class
              q.text(" < ")
              SyntaxTree::RBS::NameAndArgs.new(super_class).format(q)
            end

            q.indent do
              SyntaxTree::RBS::Members.new(self).format(q)
            end

            q.breakable(force: true)
            q.text("end")
          end
        end

        def pretty_print(q)
          q.group(2, "(class", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)

            q.pp(SyntaxTree::RBS::NameAndTypeParams.new(self))

            if super_class
              q.breakable
              q.text("super_class=")
              q.group(2, "(class", ")") do
                q.pp(SyntaxTree::RBS::NameAndArgs.new(super_class))
              end
            end

            q.breakable
            q.text("members=")
            q.pp(members)
          end
        end
      end

      class Constant
        # Prints out a constant declaration, which looks like:
        # Foo: String
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)

          q.group do
            name.format(q)
            q.text(": ")
            type.format(q)
          end
        end

        def pretty_print(q)
          q.group(2, "(constant", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)

            q.breakable
            q.text("name=")
            q.pp(name)

            q.breakable
            q.text("type=")
            q.pp(type)
          end
        end
      end

      class Global
        # Prints out a global declaration, which looks like:
        # $foo: String
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)

          q.group do
            q.text(name)
            q.text(": ")
            type.format(q)
          end
        end

        def pretty_print(q)
          q.group(2, "(global", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)

            q.breakable
            q.text("name=")
            q.pp(name)

            q.breakable
            q.text("type=")
            q.pp(type)
          end
        end
      end

      class Interface
        # Prints out an interface declaration, which looks like:
        # interface _Foo end
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          q.group do
            q.text("interface ")
            SyntaxTree::RBS::NameAndTypeParams.new(self).format(q)
            q.indent { SyntaxTree::RBS::Members.new(self).format(q) }
            q.breakable(force: true)
            q.text("end")
          end
        end

        def pretty_print(q)
          q.group(2, "(interface", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)

            q.pp(SyntaxTree::RBS::NameAndTypeParams.new(self))

            q.breakable
            q.text("members=")
            q.pp(members)
          end
        end
      end

      class Module
        # Prints out a module declaration, which looks like:
        # module Foo end
        def format(q)
          SyntaxTree::RBS::Comment.maybe_format(q, comment)
          SyntaxTree::RBS::Annotations.maybe_format(q, annotations)

          q.group do
            q.text("module ")
            SyntaxTree::RBS::NameAndTypeParams.new(self).format(q)

            if self_types.any?
              q.text(" : ")
              q.seplist(self_types, -> { q.text(", ") }) do |self_type|
                SyntaxTree::RBS::NameAndArgs.new(self_type).format(q)
              end
            end

            q.indent { SyntaxTree::RBS::Members.new(self).format(q) }
            q.breakable(force: true)
            q.text("end")
          end
        end

        def pretty_print(q)
          q.group(2, "(module", ")") do
            SyntaxTree::RBS::Comment.maybe_pretty_print(q, comment)
            SyntaxTree::RBS::Annotations.maybe_pretty_print(q, annotations)

            q.pp(SyntaxTree::RBS::NameAndTypeParams.new(self))

            if self_types.any?
              q.breakable
              q.text("self_types=")
              q.group(2, "[", "]") do
                q.seplist(self_types) do |self_type|
                  q.group(2, "(self-type", ")") do
                    q.pp(SyntaxTree::RBS::NameAndArgs.new(self_type))
                  end
                end
              end
            end

            q.breakable
            q.text("members=")
            q.pp(members)
          end
        end
      end
    end
  end
end
