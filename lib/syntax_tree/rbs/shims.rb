# frozen_string_literal: true

require "delegate"

# Previously there were specialized types that didn't include some additional
# information for type params. So here we wrap them up in order to maintain the
# same API.
module TypeParams
  class TypeParam < SimpleDelegator
    def unchecked?
      false
    end

    def upper_bound
      nil
    end
  end

  # Overriding the type params method to return an array of wrapped objects.
  def type_params
    super.params.map { |param| TypeParam.new(param) }
  end
end

module RBS::AST::Declarations
  Alias.prepend(TypeParams)
  Class.prepend(TypeParams)
  Interface.prepend(TypeParams)
  Module.prepend(TypeParams)
end
