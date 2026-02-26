# typed: strict
# frozen_string_literal: true

return unless defined?(SorbetModelEnum::ModelConcern)

module Tapioca
  module Dsl
    module Compilers
      # rubocop:disable Layout/LeadingCommentSpace
      #: [ConstantType = singleton(::ActiveRecord::Base)]
      # rubocop:enable Layout/LeadingCommentSpace
      class SorbetEnum < Compiler
        extend T::Sig

        class << self
          extend T::Sig

          sig { override.returns(T::Enumerable[Module]) }
          def gather_constants
            descendants_of(::ActiveRecord::Base).select do |klass|
              klass.respond_to?(:_sorbet_enum_definitions) &&
                klass._sorbet_enum_definitions.any?
            end
          end
        end

        sig { override.void }
        def decorate
          definitions = constant._sorbet_enum_definitions
          return if definitions.empty?

          root.create_path(constant) do |klass|
            definitions.each do |attr_name, config|
              enum_class = config[:enum_class]
              enum_type = T.must(enum_class.name)

              create_getter(klass, attr_name.to_s, enum_type)
              create_setter(klass, attr_name.to_s, enum_type)
            end
          end
        end

        sig { params(klass: RBI::Scope, name: String, enum_type: String).void }
        private def create_getter(klass, name, enum_type)
          klass.create_method(
            name,
            return_type: "T.nilable(::#{enum_type})",
          )
        end

        sig { params(klass: RBI::Scope, name: String, enum_type: String).void }
        private def create_setter(klass, name, enum_type)
          klass.create_method(
            "#{name}=",
            parameters: [
              create_param("value", type: "T.nilable(T.any(::#{enum_type}, String, Symbol, Integer))"),
            ],
            return_type: "void",
          )
        end
      end
    end
  end
end
