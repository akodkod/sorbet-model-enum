# typed: false
# frozen_string_literal: true

module SorbetModelEnum
  class Railtie < ::Rails::Railtie
    initializer "sorbet_enum.include_model_concern" do
      ActiveSupport.on_load(:active_record) do
        include SorbetModelEnum::ModelConcern
      end
    end
  end
end
