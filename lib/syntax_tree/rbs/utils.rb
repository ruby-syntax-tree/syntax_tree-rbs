# frozen_string_literal: true

module SyntaxTree
  module RBS
    # An annotation can be attached to many kinds of nodes, and should be
    # printed using %a{}. This class wraps a set of annotations and provides the
    # ability to print them if they are found.
    class Annotations
      attr_reader :annotations

      def initialize(annotations)
        @annotations = annotations
      end

      def format(q)
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

      def pretty_print(q)
        q.seplist(annotations) do |annotation|
          q.group(2, "(annotation", ")") do
            q.breakable
            q.pp(annotation.string)
          end
        end
      end

      def self.maybe_format(q, annotations)
        new(annotations).format(q) if annotations.any?
      end

      def self.maybe_pretty_print(q, annotations)
        if annotations.any?
          q.breakable
          q.text("annotations=")
          q.pp(new(annotations))
        end
      end
    end

    # A comment can be attached to many kinds of nodes, and should be printed
    # before them. This class wraps a comment and provides the ability to print
    # it if it is found.
    class Comment
      attr_reader :comment

      def initialize(comment)
        @comment = comment
      end

      # Comments come in as one whole string, so here we split it up into
      # multiple lines and then prefix it with the pound sign.
      def format(q)
        q.seplist(comment.string.split(/\r?\n/), -> { q.breakable(force: true) }) do |line|
          q.text("# #{line}")
        end
        q.breakable(force: true)
      end

      def pretty_print(q)
        q.group(2, "(comment", ")") do
          q.breakable
          q.pp(comment.string)
        end
      end

      def self.maybe_format(q, comment)
        new(comment).format(q) if comment
      end

      def self.maybe_pretty_print(q, comment)
        if comment
          q.breakable
          q.text("comment=")
          q.pp(new(comment))
        end
      end
    end

    # Certain nodes are names with optional arguments attached, as in Array[A].
    # We handle all of that printing centralized here.
    class NameAndArgs
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        q.group do
          node.name.format(q)

          if node.args.any?
            q.text("[")
            q.seplist(node.args, -> { q.text(", ") }) { |arg| arg.format(q) }
            q.text("]")
          end
        end
      end

      def pretty_print(q)
        q.breakable
        q.pp(node.name)

        if node.args.any?
          q.breakable
          q.pp(node.args)
        end
      end
    end

    # Prints out the name of a class, interface, or module declaration.
    # Additionally loops through each type parameter if there are any and print
    # them out joined by commas. Checks for validation and variance.
    class NameAndTypeParams
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        node.name.format(q)
        return if node.type_params.empty?

        q.text("[")
        q.seplist(node.type_params, -> { q.text(", ") }) do |param|
          parts = []

          if param.unchecked?
            parts << "unchecked"
          end

          if param.variance == :covariant
            parts << "out"
          elsif param.variance == :contravariant
            parts << "in"
          end

          parts << param.name
          q.text(parts.join(" "))

          if param.upper_bound
            q.text(" < ")
            param.upper_bound.format(q)
          end
        end

        q.text("]")
      end

      def pretty_print(q)
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

    # Nodes which have members will all flow their printing through this class,
    # which keeps track of 
    class Members
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        last_line = nil

        node.members.each do |member|
          q.breakable(force: true)

          if last_line && (member.location.start_line - last_line >= 2)
            q.breakable(force: true)
          end

          member.format(q)
          last_line = member.location.end_line
        end
      end
    end

    # Prints out a specific method signature, which looks like:
    # (T t) -> void
    class MethodSignature
      class OptionalPositional
        attr_reader :param

        def initialize(param)
          @param = param
        end

        def format(q)
          q.text("?")
          param.format(q)
        end
      end

      class RestPositional
        attr_reader :param

        def initialize(param)
          @param = param
        end

        def format(q)
          q.text("*")
          param.format(q)
        end
      end

      class RequiredKeyword
        attr_reader :name, :param

        def initialize(name, param)
          @name = name
          @param = param
        end

        def format(q)
          q.text(name)
          q.text(": ")
          param.format(q)
        end
      end

      class OptionalKeyword
        attr_reader :name, :param

        def initialize(name, param)
          @name = name
          @param = param
        end

        def format(q)
          q.text("?")
          q.text(name)
          q.text(": ")
          param.format(q)
        end
      end

      class RestKeyword
        attr_reader :param

        def initialize(param)
          @param = param
        end

        def format(q)
          q.text("**")
          param.format(q)
        end
      end

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
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

          params = [
            *node.type.required_positionals,
            *node.type.optional_positionals.map { |param| OptionalPositional.new(param) },
            *(RestPositional.new(node.type.rest_positionals) if node.type.rest_positionals),
            *node.type.trailing_positionals,
            *node.type.required_keywords.map { |name, param| RequiredKeyword.new(name, param) },
            *node.type.optional_keywords.map { |name, param| OptionalKeyword.new(name, param) },
            *(RestKeyword.new(node.type.rest_keywords) if node.type.rest_keywords)
          ]

          if params.any?
            q.text("(")
            q.indent do
              q.breakable("")
              q.seplist(params) { |param| param.format(q) }
            end
            q.breakable("")
            q.text(") ")
          end

          if node.respond_to?(:block) && node.block
            q.text("?") unless node.block.required
            q.text("{")
            q.indent do
              q.breakable
              MethodSignature.new(node.block).format(q)
            end
            q.breakable
            q.text("} ")
          end

          q.text("-> ")
          q.force_parens { node.type.return_type.format(q) }
        end
      end

      def pretty_print(q)
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
            q.pp(MethodSignature.new(node.block))
          end
        end

        q.breakable
        q.text("return_type=")
        q.pp(node.type.return_type)
      end
    end
  end
end
