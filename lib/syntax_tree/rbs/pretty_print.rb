# frozen_string_literal: true

module SyntaxTree
  module RBS
    class PrettyPrint < Visitor
      attr_reader :q

      def initialize(q)
        @q = q
      end

      def visit_base_type(node)
        q.text("(#{node.class.name.downcase})")
      end

      # Visit a RBS::AST::Members::Alias node.
      def visit_alias(node)
        group("alias") do
          print_comment(node)
          print_annotations(node)
          bool_field("singleton") if node.kind == :singleton
          pp_field("new_name", node.new_name)
          pp_field("old_name", node.old_name)
        end
      end

      # Visit a RBS::Types::Alias node.
      def visit_alias_type(node)
        group("alias") { visit_field("name", node.name) }
      end

      # Visit a RBS::Types::Bases::Any node.
      alias visit_any_type visit_base_type

      # Visit a RBS::AST::Members::AttrAccessor node.
      def visit_attr_accessor_member(node)
        group("attr-accessor") do
          print_comment(node)
          print_annotations(node)
          print_attribute(node)
        end
      end

      # Visit a RBS::AST::Members::AttrReader node.
      def visit_attr_reader_member(node)
        group("attr-reader") do
          print_comment(node)
          print_annotations(node)
          print_attribute(node)
        end
      end

      # Visit a RBS::AST::Members::AttrWriter node.
      def visit_attr_writer_member(node)
        group("attr-writer") do
          print_comment(node)
          print_annotations(node)
          print_attribute(node)
        end
      end

      # Visit a RBS::Types::Bases::Bool node.
      alias visit_bool_type visit_base_type

      # Visit a RBS::Types::Bases::Bottom node.
      alias visit_bottom_type visit_base_type

      # Visit a RBS::AST::Declarations::Class node.
      def visit_class_declaration(node)
        group("class") do
          print_comment(node)
          print_annotations(node)
          print_name_and_type_params(node)

          if node.super_class
            q.breakable
            q.text("super_class=")
            print_name_and_args(node.super_class)
          end

          pp_field("members", node.members)
        end
      end

      # Visit a RBS::Types::ClassInstance node.
      def visit_class_instance_type(node)
        group("class-instance") { print_name_and_args(node) }
      end

      # Visit a RBS::AST::Members::ClassInstanceVariable node.
      def visit_class_instance_variable_member(node)
        group("class-instance-variable") do
          print_comment(node)
          pp_field("name", node.name)
        end
      end

      # Visit a RBS::Types::ClassSingleton node.
      def visit_class_singleton_type(node)
        group("class-singleton") { pp_field("name", node.name) }
      end

      # Visit a RBS::Types::Bases::Class node.
      alias visit_class_type visit_base_type

      # Visit a RBS::AST::Members::ClassVariable node.
      def visit_class_variable_member(node)
        group("class-variable") do
          print_comment(node)
          pp_field("name", node.name)
        end
      end

      # Visit a RBS::AST::Declarations::Constant node.
      def visit_constant_declaration(node)
        group("constant") do
          print_comment(node)
          visit_field("name", node.name)
          visit_field("type", node.type)
        end
      end

      # Visit a RBS::AST::Members::Extend node.
      def visit_extend_member(node)
        group("extend") do
          print_comment(node)
          print_annotations(node)
          print_name_and_args(node)
        end
      end

      # Visit a RBS::Types::Function::Param node.
      def visit_function_param_type(node)
        group("param") do
          visit_field("type", node.type)
          pp_field("name", node.name) if node.name
        end
      end

      # Visit a RBS::AST::Declarations::Global node.
      def visit_global_declaration(node)
        group("global") do
          print_comment(node)
          pp_field("name", node.name)
          visit_field("type", node.type)
        end
      end

      # Visit a RBS::AST::Members::Include node.
      def visit_include_member(node)
        group("include") do
          print_comment(node)
          print_annotations(node)
          print_name_and_args(node)
        end
      end

      # Visit a RBS::Types::Bases::Instance node.
      alias visit_instance_type visit_base_type

      # Visit a RBS::AST::Members::InstanceVariable node.
      def visit_instance_variable_member(node)
        group("instance-variable") do
          print_comment(node)
          pp_field("name", node.name)
        end
      end

      # Visit a RBS::AST::Declarations::Interface node.
      def visit_interface_declaration(node)
        group("interface") do
          print_comment(node)
          print_annotations(node)
          print_name_and_type_params(node)
          pp_field("members", node.members)
        end
      end

      # Visit a RBS::Types::Interface node.
      def visit_interface_type(node)
        group("interface") { print_name_and_args(node) }
      end

      # Visit a RBS::Types::Intersection node.
      def visit_intersection_type(node)
        group("intersection") { pp_field("types", node.types) }
      end

      # Visit a RBS::Types::Literal node.
      def visit_literal_type(node)
        group("literal") { pp_field("literal", node.literal) }
      end

      # Visit a RBS::AST::Members::MethodDefinition node.
      def visit_method_definition_member(node)
        group("(method-definition") do
          print_comment(node)
          print_annotations(node)
          pp_field("kind", node.kind)
          pp_field("name", node.name)
          pp_field("visibility", node.visibility) if node.visibility
          bool_field("overload") if node.overloading?

          q.breakable
          q.text("overloads=")
          q.group(2, "[", "]") do
            q.seplist(node.overloads) do |overload|
              print_method_overload(overload)
            end
          end
        end
      end

      # Visit a RBS::AST::Declarations::Module node.
      def visit_module_declaration(node)
        group("module") do
          print_comment(node)
          print_annotations(node)
          print_name_and_type_params(node)

          if node.self_types.any?
            q.breakable
            q.text("self_types=")
            q.group(2, "[", "]") do
              q.seplist(node.self_types) do |self_type|
                print_name_and_args(self_type)
              end
            end
          end

          pp_field("members", node.members)
        end
      end

      # Visit a RBS::Types::Bases::Nil node.
      alias visit_nil_type visit_base_type

      # Visit a RBS::Types::Optional node.
      def visit_optional_type(node)
        group("optional") { visit_field("type", node.type) }
      end

      # Visit a RBS::AST::Members::Prepend node.
      def visit_prepend_member(node)
        group("prepend") do
          print_comment(node)
          print_annotations(node)
          print_name_and_args(node)
        end
      end

      # Visit a RBS::AST::Members::Private node.
      def visit_private_member(node)
        q.text("(private)")
      end

      # Visit a RBS::Types::Proc node.
      def visit_proc_type(node)
        group("proc") { print_method_signature(node) }
      end

      # Visit a RBS::AST::Members::Public node.
      def visit_public_member(node)
        q.text("(public)")
      end

      # Visit a RBS::Types::Record node.
      def visit_record_type(node)
        group("record") { pp_field("fields", node.fields) }
      end

      # Visit a SyntaxTree::RBS::Root node.
      def visit_root(node)
        group("root") { pp_field("declarations", node.declarations) }
      end

      # Visit a RBS::Types::Self node.
      alias visit_self_type visit_base_type

      # Visit a RBS::Types::Top node.
      alias visit_top_type visit_base_type

      # Visit a RBS::Types::Tuple node.
      def visit_tuple_type(node)
        group("tuple") { pp_field("types", node.types) }
      end

      # Visit a RBS::AST::Declarations::TypeAlias node.
      def visit_type_alias(node)
        group("constant") do
          print_comment(node)
          print_annotations(node)
          visit_field("name", node.name)
          visit_field("type", node.type)
        end
      end

      # Visit a RBS::TypeName node.
      def visit_type_name(node)
        group("type-name") do
          q.breakable
          q.pp(node.to_s)
        end
      end

      # Visit a RBS::Types::Union node.
      def visit_union_type(node)
        group("union") { pp_field("types", node.types) }
      end

      # Visit a RBS::Types::Variable node.
      def visit_variable_type(node)
        group("variable") { pp_field("name", node.name) }
      end

      # Visit a RBS::Types::Bases::Void node.
      alias visit_void_type visit_base_type

      private

      #-------------------------------------------------------------------------
      # Printing structure
      #-------------------------------------------------------------------------

      def group(name)
        q.group do
          q.text("(")
          q.text(name)
          q.nest(2) { yield }
          q.breakable("")
          q.text(")")
        end
      end

      def bool_field(name)
        q.breakable
        q.text(name)
      end

      def pp_field(name, field)
        q.breakable
        q.text("#{name}=")
        q.pp(field)
      end

      def visit_field(name, field)
        q.breakable
        q.text("#{name}=")
        visit(field)
      end

      #-------------------------------------------------------------------------
      # Printing certain kinds of nodes
      #-------------------------------------------------------------------------

      def print_annotations(node)
        annotations = node.annotations
        return if annotations.empty?

        q.breakable
        q.text("annotations=")
        q.seplist(annotations) do |annotation|
          q.group(2, "(annotation", ")") do
            q.breakable
            q.pp(annotation.string)
          end
        end
      end

      def print_attribute(node)
        if node.kind == :singleton
          q.breakable
          q.text("singleton")
        end

        q.breakable
        q.text("name=")
        q.pp(node.name)

        if node.visibility
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

      def print_comment(node)
        comment = node.comment
        return unless comment

        q.breakable
        q.text("comment=")
        q.group(2, "(comment", ")") do
          q.breakable
          q.pp(comment.string)
        end
      end

      def print_method_overload(node)
        print_method_signature(node.method_type)
      end

      def print_method_signature(node)
        if node.respond_to?(:type_params) && node.type_params.any?
          q.breakable
          q.text("type_params=")
          q.group(2, "[", "]") do
            q.breakable("")
            q.seplist(node.type_params) do |param|
              q.group(2, "(type-param", ")") do
                q.breakable
                q.text("name=")
                q.pp(param.name)
              end
            end
            q.breakable("")
          end
        end

        if node.type.required_positionals.any?
          q.breakable
          q.text("required_positionals=")
          q.pp(node.type.required_positionals)
        end

        if node.type.optional_positionals.any?
          q.breakable
          q.text("optional_positionals=")
          q.pp(node.type.optional_positionals)
        end

        if node.type.rest_positionals
          q.breakable
          q.text("rest_positionals=")
          q.pp(node.type.rest_positionals)
        end

        if node.type.trailing_positionals.any?
          q.breakable
          q.text("trailing_positionals=")
          q.pp(node.type.trailing_positionals)
        end

        if node.type.required_keywords.any?
          q.breakable
          q.text("required_keywords=")
          q.pp(node.type.required_keywords)
        end

        if node.type.optional_keywords.any?
          q.breakable
          q.text("optional_keywords=")
          q.pp(node.type.optional_keywords)
        end

        if node.type.rest_keywords
          q.breakable
          q.text("rest_keywords=")
          q.pp(node.type.rest_keywords)
        end

        if node.respond_to?(:block) && node.block
          q.breakable
          q.text("block=")
          q.group(2, "(block", ")") do
            if node.block.required
              q.breakable
              q.text("required")
            end

            q.breakable
            print_method_signature(node.block)
          end
        end

        q.breakable
        q.text("return_type=")
        q.pp(node.type.return_type)
      end

      def print_name_and_args(node)
        q.breakable
        q.pp(node.name)

        if node.args.any?
          q.breakable
          q.pp(node.args)
        end
      end

      def print_name_and_type_params(node)
        q.breakable
        q.pp(node.name)

        if node.type_params.any?
          q.breakable
          q.group(2, "type_params=[", "]") do
            q.seplist(node.type_params) do |param|
              q.group(2, "(type-param", ")") do
                if param.unchecked?
                  q.breakable
                  q.text("unchecked")
                end

                if param.variance == :covariant
                  q.breakable
                  q.text("covariant")
                elsif param.variance == :contravariant
                  q.breakable
                  q.text("contravariant")
                end

                q.breakable
                q.text("name=")
                q.pp(param.name)

                if param.upper_bound
                  q.breakable
                  q.text("upper_bound=")
                  q.pp(param.upper_bound)
                end
              end
            end
          end
        end
      end
    end
  end
end
