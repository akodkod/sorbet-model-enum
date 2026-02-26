# typed: strict
# frozen_string_literal: true

require "active_record"
require "sorbet-runtime"

require "sorbet-model-enum/version"
require "sorbet-model-enum/model_concern"
require "sorbet-model-enum/railtie" if defined?(Rails)

module SorbetModelEnum
  class Error < StandardError; end
end
