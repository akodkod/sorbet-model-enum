# typed: true
# frozen_string_literal: true

module SorbetModelEnum
  module ModelConcern
    module ClassMethods
      sig do
        params(
          attr_name: T.any(Symbol, String),
          enum_class: T.class_of(T::Enum),
          options: T.untyped,
        ).void
      end
      def sorbet_enum(attr_name, enum_class, **options); end
    end
  end
end
