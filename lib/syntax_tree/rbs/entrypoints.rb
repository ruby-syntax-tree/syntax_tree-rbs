# frozen_string_literal: true

module SyntaxTree
  module RBS
    # These are the methods that are going to be defined on each node of the
    # AST. They each will create a visitor and enter into the visitor's walking
    # algorithm.
    module Entrypoints
      def format(q)
        accept(Format.new(q))
      end

      def pretty_print(q)
        accept(PrettyPrint.new(q))
      end
    end

    # This is the root node of the entire tree. It contains all of the top-level
    # declarations within the file.
    class Root
      include Entrypoints

      attr_reader :declarations

      def initialize(declarations)
        @declarations = declarations
      end

      def accept(visitor)
        visitor.visit_root(self)
      end
    end
  end
end

module RBS
  class TypeName
    include SyntaxTree::RBS::Entrypoints

    def accept(visitor)
      visitor.visit_type_name(self)
    end
  end

  module AST
    module Declarations
      class Base
        include SyntaxTree::RBS::Entrypoints
      end

      # class Foo end
      class Class
        def accept(visitor)
          visitor.visit_class_declaration(self)
        end
      end

      # Foo: String
      class Constant
        def accept(visitor)
          visitor.visit_constant_declaration(self)
        end
      end

      # $foo: String
      class Global
        def accept(visitor)
          visitor.visit_global_declaration(self)
        end
      end

      # interface _Foo end
      class Interface
        def accept(visitor)
          visitor.visit_interface_declaration(self)
        end
      end

      # module Foo end
      class Module
        def accept(visitor)
          visitor.visit_module_declaration(self)
        end
      end

      # type foo = String
      class TypeAlias
        def accept(visitor)
          visitor.visit_type_alias(self)
        end
      end
    end

    module Members
      class Base
        include SyntaxTree::RBS::Entrypoints
      end

      # alias foo bar
      # alias self.foo self.bar
      class Alias
        def accept(visitor)
          visitor.visit_alias(self)
        end
      end

      # attr_accessor foo: Foo
      class AttrAccessor
        def accept(visitor)
          visitor.visit_attr_accessor_member(self)
        end
      end

      # attr_reader foo: Foo
      class AttrReader
        def accept(visitor)
          visitor.visit_attr_reader_member(self)
        end
      end

      # attr_writer foo: Foo
      class AttrWriter
        def accept(visitor)
          visitor.visit_attr_writer_member(self)
        end
      end

      # self.@foo: String
      class ClassInstanceVariable
        def accept(visitor)
          visitor.visit_class_instance_variable_member(self)
        end
      end

      # @@foo: String
      class ClassVariable
        def accept(visitor)
          visitor.visit_class_variable_member(self)
        end
      end

      # extend Foo
      class Extend
        def accept(visitor)
          visitor.visit_extend_member(self)
        end
      end

      # include Foo
      class Include
        def accept(visitor)
          visitor.visit_include_member(self)
        end
      end

      # @foo: String
      class InstanceVariable
        def accept(visitor)
          visitor.visit_instance_variable_member(self)
        end
      end

      # def t: (T t) -> void
      class MethodDefinition
        def accept(visitor)
          visitor.visit_method_definition_member(self)
        end
      end

      # prepend Foo
      class Prepend
        def accept(visitor)
          visitor.visit_prepend_member(self)
        end
      end

      # private
      class Private
        def accept(visitor)
          visitor.visit_private_member(self)
        end
      end

      # public
      class Public
        def accept(visitor)
          visitor.visit_public_member(self)
        end
      end
    end
  end

  module Types
    # Foo
    class Alias
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_alias_type(self)
      end
    end

    # any
    class Bases::Any
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_any_type(self)
      end
    end

    # bool
    class Bases::Bool
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_bool_type(self)
      end
    end

    # bottom
    class Bases::Bottom
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_bottom_type(self)
      end
    end

    # class
    class Bases::Class
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_class_type(self)
      end
    end

    # instance
    class Bases::Instance
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_instance_type(self)
      end
    end

    # nil
    class Bases::Nil
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_nil_type(self)
      end
    end

    # self
    class Bases::Self
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_self_type(self)
      end
    end

    # top
    class Bases::Top
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_top_type(self)
      end
    end

    # void
    class Bases::Void
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_void_type(self)
      end
    end

    # Foo
    class ClassInstance
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_class_instance_type(self)
      end
    end

    # singleton(Foo)
    class ClassSingleton
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_class_singleton_type(self)
      end
    end

    # Foo foo
    class Function::Param
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_function_param_type(self)
      end
    end

    # _Foo
    class Interface
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_interface_type(self)
      end
    end

    # foo & bar
    class Intersection
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_intersection_type(self)
      end
    end

    # 1
    class Literal
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_literal_type(self)
      end
    end

    # foo?
    class Optional
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_optional_type(self)
      end
    end

    # ^-> void
    class Proc
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_proc_type(self)
      end
    end

    # { foo: bar }
    class Record
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_record_type(self)
      end
    end

    # [foo, bar]
    class Tuple
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_tuple_type(self)
      end
    end

    # foo | bar
    class Union
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_union_type(self)
      end
    end

    # foo
    class Variable
      include SyntaxTree::RBS::Entrypoints

      def accept(visitor)
        visitor.visit_variable_type(self)
      end
    end
  end
end
