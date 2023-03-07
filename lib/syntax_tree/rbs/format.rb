# frozen_string_literal: true

module SyntaxTree
  module RBS
    class Format < Visitor
      attr_reader :q

      def initialize(q)
        @q = q
      end

      def visit_base_type(node)
        q.text(node.to_s)
      end

      # Visit a RBS::AST::Members::Alias node.
      def visit_alias(node)
        print_comment(node)
        print_annotations(node)

        if node.kind == :singleton
          q.text("alias self.")
          q.text(node.new_name)
          q.text(" self.")
          q.text(node.old_name)
        else
          q.text("alias ")
          q.text(node.new_name)
          q.text(" ")
          q.text(node.old_name)
        end
      end

      # Visit a RBS::Types::Alias node.
      def visit_alias_type(node)
        visit(node.name)
      end

      # Visit a RBS::Types::Bases::Any node.
      alias visit_any_type visit_base_type

      # Visit a RBS::AST::Members::AttrAccessor node.
      def visit_attr_accessor_member(node)
        print_comment(node)
        print_annotations(node)
        print_attribute(:accessor, node)
      end

      # Visit a RBS::AST::Members::AttrReader node.
      def visit_attr_reader_member(node)
        print_comment(node)
        print_annotations(node)
        print_attribute(:reader, node)
      end

      # Visit a RBS::AST::Members::AttrWriter node.
      def visit_attr_writer_member(node)
        print_comment(node)
        print_annotations(node)
        print_attribute(:writer, node)
      end

      # Visit a RBS::Types::Bases::Bool node.
      alias visit_bool_type visit_base_type

      # Visit a RBS::Types::Bases::Bottom node.
      alias visit_bottom_type visit_base_type

      # Visit a RBS::AST::Declarations::Class node.
      def visit_class_declaration(node)
        print_comment(node)
        print_annotations(node)

        q.group do
          q.text("class ")
          print_name_and_type_params(node)

          if node.super_class
            q.text(" < ")
            print_name_and_args(node.super_class)
          end

          q.indent { print_members(node) }
          q.breakable(force: true)
          q.text("end")
        end
      end

      # Visit a RBS::Types::ClassInstance node.
      def visit_class_instance_type(node)
        print_name_and_args(node)
      end

      # Visit a RBS::AST::Members::ClassInstanceVariable node.
      def visit_class_instance_variable_member(node)
        print_comment(node)

        q.group do
          q.text("self.")
          q.text(node.name)
          q.text(": ")
          visit(node.type)
        end
      end

      # Visit a RBS::Types::ClassSingleton node.
      def visit_class_singleton_type(node)
        q.text("singleton(")
        visit(node.name)
        q.text(")")
      end

      # Visit a RBS::Types::Bases::Class node.
      alias visit_class_type visit_base_type

      # Visit a RBS::AST::Members::ClassVariable node.
      def visit_class_variable_member(node)
        print_comment(node)

        q.group do
          q.text(node.name)
          q.text(": ")
          visit(node.type)
        end
      end

      # Visit a RBS::AST::Declarations::Constant node.
      def visit_constant_declaration(node)
        print_comment(node)

        q.group do
          visit(node.name)
          q.text(": ")
          visit(node.type)
        end
      end

      # Visit a RBS::AST::Members::Extend node.
      def visit_extend_member(node)
        print_comment(node)
        print_annotations(node)

        q.group do
          q.text("extend ")
          print_name_and_args(node)
        end
      end

      # Visit a RBS::Types::Function::Param node.
      def visit_function_param_type(node)
        visit(node.type)

        if node.name
          q.text(" ")

          if ::RBS::Parser::KEYWORDS.include?(node.name.to_s)
            q.text("`#{node.name}`")
          else
            q.text(node.name)
          end
        end
      end

      # Visit a RBS::AST::Declarations::Global node.
      def visit_global_declaration(node)
        print_comment(node)

        q.group do
          q.text(node.name)
          q.text(": ")
          visit(node.type)
        end
      end

      # Visit a RBS::AST::Members::Include node.
      def visit_include_member(node)
        print_comment(node)
        print_annotations(node)

        q.group do
          q.text("include ")
          print_name_and_args(node)
        end
      end

      # Visit a RBS::Types::Bases::Instance node.
      alias visit_instance_type visit_base_type

      # Visit a RBS::AST::Members::InstanceVariable node.
      def visit_instance_variable_member(node)
        print_comment(node)

        q.group do
          q.text(node.name)
          q.text(": ")
          visit(node.type)
        end
      end

      # Visit a RBS::AST::Declarations::Interface node.
      def visit_interface_declaration(node)
        print_comment(node)
        print_annotations(node)

        q.group do
          q.text("interface ")
          print_name_and_type_params(node)
          q.indent { print_members(node) }
          q.breakable(force: true)
          q.text("end")
        end
      end

      # Visit a RBS::Types::Interface node.
      def visit_interface_type(node)
        print_name_and_args(node)
      end

      # Visit a RBS::Types::Intersection node.
      def visit_intersection_type(node)
        separator =
          lambda do
            q.breakable
            q.text("& ")
          end

        q.text("(") if q.force_parens?
        q.group do
          q.force_parens do
            q.seplist(node.types, separator) { |type| visit(type) }
          end
        end
        q.text(")") if q.force_parens?
      end

      # Visit a RBS::Types::Literal node.
      def visit_literal_type(node)
        unless node.literal.is_a?(String)
          q.text(node.literal.inspect)
          return
        end

        # We're going to go straight to the source here, as if we don't then
        # we're going to end up with the result of String#inspect, which does
        # weird things to escape sequences.
        source = q.source[node.location.range]
        quote = source.include?("\\") ? source[0] : "\""
        source = SyntaxTree::Quotes.normalize(source[1..-2], quote)

        q.text(quote)
        q.seplist(
          source.split(/\r?\n/),
          -> { q.breakable(force: true) }
        ) { |line| q.text(line) }
        q.text(quote)
      end

      # Visit a RBS::AST::Members::MethodDefinition node.
      def visit_method_definition_member(node)
        print_comment(node)
        print_annotations(node)

        q.group do
          q.text("#{node.visibility} ") if node.visibility
          q.text("def ")

          if node.kind == :singleton
            q.text("self.")
          elsif node.kind == :singleton_instance
            q.text("self?.")
          end

          q.text(
            (
              if ::RBS::Parser::KEYWORDS.include?(node.name.to_s)
                "`#{node.name}`"
              else
                node.name
              end
            )
          )
          q.text(":")

          if node.overloads.length == 1 && !node.overloading?
            q.text(" ")
            print_method_overload(node.overloads.first)
          else
            separator =
              lambda do
                q.breakable
                q.text("| ")
              end

            q.group do
              q.indent do
                q.breakable
                q.seplist(node.overloads, separator) do |overload|
                  print_method_overload(overload)
                end

                if node.overloading?
                  separator.call
                  q.text("...")
                end
              end
            end
          end
        end
      end

      # Visit a RBS::AST::Declarations::Module node.
      def visit_module_declaration(node)
        print_comment(node)
        print_annotations(node)

        q.group do
          q.text("module ")
          print_name_and_type_params(node)

          if node.self_types.any?
            q.text(" : ")
            q.seplist(node.self_types, -> { q.text(", ") }) do |self_type|
              print_name_and_args(self_type)
            end
          end

          q.indent { print_members(node) }
          q.breakable(force: true)
          q.text("end")
        end
      end

      # Visit a RBS::Types::Bases::Nil node.
      alias visit_nil_type visit_base_type

      # Visit a RBS::Types::Optional node.
      def visit_optional_type(node)
        q.force_parens { visit(node.type) }
        q.text("?")
      end

      # Visit a RBS::AST::Members::Prepend node.
      def visit_prepend_member(node)
        print_comment(node)
        print_annotations(node)

        q.group do
          q.text("prepend ")
          print_name_and_args(node)
        end
      end

      # Visit a RBS::AST::Members::Private node.
      def visit_private_member(node)
        q.text("private")
      end

      # Visit a RBS::Types::Proc node.
      def visit_proc_type(node)
        q.group do
          q.text("(") if q.force_parens?
          q.text("^")
          print_method_signature(node)
          q.text(")") if q.force_parens?
        end
      end

      # Visit a RBS::AST::Members::Public node.
      def visit_public_member(node)
        q.text("public")
      end

      # Visit a RBS::Types::Record node.
      def visit_record_type(node)
        separator =
          lambda do
            q.text(",")
            q.breakable
          end

        q.group do
          q.text("{")
          q.indent do
            q.breakable
            q.seplist(node.fields, separator, :each_pair) do |key, type|
              if key.is_a?(Symbol) && key.match?(/\A[A-Za-z_][A-Za-z_]*\z/)
                q.text("#{key}: ")
              else
                q.text("#{key.inspect} => ")
              end

              visit(type)
            end
          end
          q.breakable
          q.text("}")
        end
      end

      # Visit a SyntaxTree::RBS::Root node.
      def visit_root(node)
        separator =
          lambda do
            q.breakable(force: true)
            q.breakable(force: true)
          end

        q.seplist(node.declarations, separator) do |declaration|
          visit(declaration)
        end

        q.breakable(force: true)
      end

      # Visit a RBS::Types::Self node.
      alias visit_self_type visit_base_type

      # Visit a RBS::Types::Top node.
      alias visit_top_type visit_base_type

      # Visit a RBS::Types::Tuple node.
      def visit_tuple_type(node)
        # If we don't have any sub types, we explicitly need the space in
        # between the brackets to not confuse the parser.
        if node.types.empty?
          q.text("[ ]")
          return
        end

        q.group do
          q.text("[")
          q.seplist(node.types, -> { q.text(", ") }) { |type| visit(type) }
          q.text("]")
        end
      end

      # Visit a RBS::AST::Declarations::TypeAlias node.
      def visit_type_alias(node)
        print_comment(node)
        print_annotations(node)

        q.group do
          q.text("type ")
          visit(node.name)
          q.text(" =")
          q.group do
            q.indent do
              q.breakable
              visit(node.type)
            end
          end
        end
      end

      # Visit a RBS::TypeName node.
      def visit_type_name(node)
        q.text(node.to_s)
      end

      # Visit a RBS::Types::Union node.
      def visit_union_type(node)
        separator =
          lambda do
            q.breakable
            q.text("| ")
          end

        q.text("(") if q.force_parens?
        q.group { q.seplist(node.types, separator) { |type| visit(type) } }
        q.text(")") if q.force_parens?
      end

      # Visit a RBS::Types::Variable node.
      def visit_variable_type(node)
        q.text(node.name)
      end

      # Visit a RBS::Types::Bases::Void node.
      alias visit_void_type visit_base_type

      private

      # An annotation can be attached to many kinds of nodes, and should be
      # printed using %a{}.
      def print_annotations(node)
        annotations = node.annotations
        return if annotations.empty?

        q.seplist(annotations, -> { q.breakable(force: true) }) do |annotation|
          if annotation.string.match?(/[{}]/)
            # Bail out and just print the source string if there are any braces
            # because we don't want to mess with escaping them.
            q.text(q.source[annotation.location.range])
          else
            q.text("%a{")
            q.text(annotation.string)
            q.text("}")
          end
        end
        q.breakable(force: true)
      end

      def print_attribute(type, node)
        q.group do
          q.text("#{node.visibility} ") if node.visibility
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
          visit(node.type)
        end
      end

      # Comments come in as one whole string, so here we split it up into
      # multiple lines and then prefix it with the pound sign.
      def print_comment(node)
        comment = node.comment
        return unless comment

        q.seplist(
          comment.string.split(/\r?\n/),
          -> { q.breakable(force: true) }
        ) { |line| q.text("# #{line}") }
        q.breakable(force: true)
      end

      # Nodes which have members will all flow their printing through this
      # class, which keeps track of
      def print_members(node)
        last_line = nil

        node.members.each do |member|
          q.breakable(force: true)

          if last_line && (member.location.start_line - last_line >= 2)
            q.breakable(force: true)
          end

          visit(member)
          last_line = member.location.end_line
        end
      end

      # (T t) -> void
      def print_method_overload(node)
        print_method_signature(node.method_type)
      end

      # (T t) -> void
      def print_method_signature(node)
        q.group do
          # We won't have a type_params key if we're printing a block
          if node.respond_to?(:type_params) && node.type_params.any?
            q.text("[")
            q.seplist(node.type_params, -> { q.text(", ") }) do |param|
              # We need to do a type check here to support RBS 1.0
              q.text(param.is_a?(Symbol) ? param.to_s : param.name)
            end
            q.text("] ")
          end

          params = []

          # Directly visit each of the required positional parameters.
          node.type.required_positionals.each do |param|
            params << -> { visit(param) }
          end

          # Prefix each of the optional positional parameters with a ?.
          node.type.optional_positionals.each do |param|
            params << -> do
              q.text("?")
              visit(param)
            end
          end

          # If a rest positional is present, print it and prefix it with a *.
          if node.type.rest_positionals
            params << -> do
              q.text("*")
              visit(node.type.rest_positionals)
            end
          end

          # Directly visit any required positional parameters that occur after
          # the rest positional.
          node.type.trailing_positionals.each do |param|
            params << -> { visit(param) }
          end

          # Print all of the required keyword parameters with their name and
          # parameter separated by a colon.
          node.type.required_keywords.each do |name, param|
            params << -> do
              q.text(name)
              q.text(": ")
              visit(param)
            end
          end

          # Print all of the required keyword parameters with their name and
          # parameter separated by a colon, prefixed by a ?.
          node.type.optional_keywords.each do |name, param|
            params << -> do
              q.text("?")
              q.text(name)
              q.text(": ")
              visit(param)
            end
          end

          # Print the rest keyword parameter if it exists by prefixing it with
          # a ** operator.
          if node.type.rest_keywords
            params << -> do
              q.text("**")
              visit(node.type.rest_keywords)
            end
          end

          if params.any?
            q.text("(")
            q.indent do
              q.breakable("")
              q.seplist(params, &:call)
            end
            q.breakable("")
            q.text(") ")
          end

          if node.respond_to?(:block) && node.block
            q.text("?") unless node.block.required
            q.text("{")
            q.indent do
              q.breakable
              print_method_signature(node.block)
            end
            q.breakable
            q.text("} ")
          end

          q.text("-> ")
          q.force_parens { visit(node.type.return_type) }
        end
      end

      # Certain nodes are names with optional arguments attached, as in
      # Array[A]. We handle all of that printing centralized here.
      def print_name_and_args(node)
        q.group do
          visit(node.name)

          if node.args.any?
            q.text("[")
            q.seplist(node.args, -> { q.text(", ") }) { |arg| visit(arg) }
            q.text("]")
          end
        end
      end

      # Prints out the name of a class, interface, or module declaration.
      # Additionally loops through each type parameter if there are any and
      # print them out joined by commas. Checks for validation and variance.
      def print_name_and_type_params(node)
        visit(node.name)
        return if node.type_params.empty?

        q.text("[")
        q.seplist(node.type_params, -> { q.text(", ") }) do |param|
          parts = []

          parts << "unchecked" if param.unchecked?

          if param.variance == :covariant
            parts << "out"
          elsif param.variance == :contravariant
            parts << "in"
          end

          parts << param.name
          q.text(parts.join(" "))

          if param.upper_bound
            q.text(" < ")
            visit(param.upper_bound)
          end
        end

        q.text("]")
      end
    end
  end
end
