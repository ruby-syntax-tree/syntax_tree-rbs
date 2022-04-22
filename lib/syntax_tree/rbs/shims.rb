# frozen_string_literal: true

if defined?(RBS::AST::Declarations::ModuleTypeParams)
  require "delegate"

  # Previously there were specialized types that didn't include some additional
  # information for type params. So here we wrap them up in order to maintain the
  # same API.
  module ShimTypeParams
    class ShimTypeParam < SimpleDelegator
      def unchecked?
        false
      end

      def upper_bound
        nil
      end
    end

    # Overriding the type params method to return an array of wrapped objects.
    def type_params
      super.params.map { |param| ShimTypeParam.new(param) }
    end
  end

  module RBS::AST::Declarations
    Alias.prepend(ShimTypeParams)
    Class.prepend(ShimTypeParams)
    Interface.prepend(ShimTypeParams)
    Module.prepend(ShimTypeParams)
  end
end

# Previously this attribute didn't exist on some nodes. So if they don't have
# it, we're just going to apply it and have it return nil.
module ShimVisibility
  def visibility
  end
end

module RBS::AST::Members
  [AttrAccessor, AttrReader, AttrWriter, MethodDefinition].each do |klass|
    klass.include(ShimVisibility) unless klass.method_defined?(:visibility)
  end
end
