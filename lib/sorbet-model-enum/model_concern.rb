# typed: false
# frozen_string_literal: true

module SorbetModelEnum
  module ModelConcern
    extend ActiveSupport::Concern

    included do
      class_attribute :_sorbet_enum_definitions, instance_writer: false, default: {}
    end

    class_methods do # rubocop:disable Metrics/BlockLength
      def sorbet_enum(attr_name, enum_class, **options)
        attr_name = attr_name.to_sym

        raise ArgumentError, "#{enum_class} must be a T::Enum subclass" unless enum_class < T::Enum

        mapping = _build_enum_mapping(enum_class)

        self._sorbet_enum_definitions = _sorbet_enum_definitions.merge(
          attr_name => { enum_class: enum_class, mapping: mapping },
        )

        enum(attr_name, mapping, **options)

        _define_sorbet_enum_getter(attr_name, enum_class)
        _define_sorbet_enum_setter(attr_name)
      end

      private def _build_enum_mapping(enum_class)
        enum_class.values.each_with_object({}) do |enum_value, mapping|
          const_name = enum_class.constants(false).find do |name|
            enum_class.const_get(name).equal?(enum_value)
          end

          next unless const_name

          key = const_name.to_s.underscore
          mapping[key] = enum_value.serialize
        end
      end

      private def _define_sorbet_enum_getter(attr_name, enum_class)
        define_method(attr_name) do
          rails_value = super()
          return nil if rails_value.nil?

          serialized = self.class.send(attr_name.to_s.pluralize)[rails_value]
          enum_class.deserialize(serialized)
        end
      end

      private def _define_sorbet_enum_setter(attr_name)
        define_method(:"#{attr_name}=") do |value|
          if value.is_a?(T::Enum)
            mapping = self.class._sorbet_enum_definitions[attr_name][:mapping]
            string_key = mapping.key(value.serialize)
            super(string_key)
          else
            super(value)
          end
        end
      end
    end
  end
end
