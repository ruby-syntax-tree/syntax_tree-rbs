# frozen_string_literal: true

# If we're using RBS 1, then we need to include these monkey-patches to have a
# consistent interface in RBS 2+.
if RBS::VERSION < "2.0.0"
  require "delegate"

  module RBS::AST::Declarations
    class ShimTypeParam < SimpleDelegator
      def unchecked?
        false
      end

      def upper_bound
        nil
      end
    end

    # Previously there were specialized types that didn't include some
    # additional information for type params. So here we wrap them up in order
    # to maintain the same API.
    module ShimTypeParams
      def type_params
        super.params.map { |param| ShimTypeParam.new(param) }
      end
    end

    Alias.prepend(ShimTypeParams)
    Class.prepend(ShimTypeParams)
    Interface.prepend(ShimTypeParams)
    Module.prepend(ShimTypeParams)
  end

  module RBS::AST::Members::Attribute
    def visibility
    end
  end

  class RBS::AST::Members::MethodDefinition
    def visibility
    end
  end
end

# If we're using RBS 2, then we need to include these monkey-patches to have a
# consistent interface in RBS 3+.
if RBS::VERSION < "3.0.0"
  class RBS::AST::Declarations::Alias
    def accept(visitor)
      visitor.visit_type_alias(self)
    end
  end

  class RBS::AST::Members::MethodDefinition
    class MethodOverloadShim
      attr_reader :method_type

      def initialize(method_type)
        @method_type = method_type
      end
    end

    alias overloading? overload?

    def overloads
      types.map { |method_type| MethodOverloadShim.new(method_type) }
    end
  end

  module SyntaxTree::RBS
    class << self
      undef parse
      def parse(source)
        Root.new(::RBS::Parser.parse_signature(source))
      end
    end
  end
end
