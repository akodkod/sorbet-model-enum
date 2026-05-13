# frozen_string_literal: true

require "spec_helper"
require "tapioca/dsl"
require "tapioca/dsl/compilers/sorbet_enum"

RSpec.describe Tapioca::Dsl::Compilers::SorbetEnum do
  def rbi_for(constant)
    file = RBI::File.new(strictness: "true")
    pipeline = Tapioca::Dsl::Pipeline.new(
      requested_constants: [constant],
      requested_compilers: [described_class],
    )

    compiler = described_class.new(pipeline, file.root, constant)
    compiler.decorate

    file.root.string
  end

  describe ".gather_constants" do
    it "includes models with sorbet_enum" do
      expect(described_class.processable_constants).to include(User)
    end

    it "excludes ActiveRecord::Base itself" do
      expect(described_class.processable_constants).not_to include(ActiveRecord::Base)
    end
  end

  describe "#decorate" do
    it "generates correct getter and setter signatures" do
      output = rbi_for(User)

      expect(output).to include("def status; end")
      expect(output).to include("def role; end")
      expect(output).to include("def priority; end")
      expect(output).to include("def status=(value); end")
      expect(output).to include("def role=(value); end")
      expect(output).to include("def priority=(value); end")
    end

    it "generates non-nilable return type for getter by default" do
      output = rbi_for(User)

      expect(output).to include("returns(::UserStatus)")
      expect(output).to include("returns(::UserRole)")
      expect(output).not_to include("returns(T.nilable(::UserRole))")
    end

    it "generates nilable return type for getter when optional: true" do
      output = rbi_for(User)

      expect(output).to include("returns(T.nilable(::UserPriority))")
    end

    it "generates union type for setter parameter" do
      output = rbi_for(User)

      expect(output).to include(
        "params(value: T.nilable(T.any(::UserStatus, String, Symbol, Integer)))",
      )
      expect(output).to include(
        "params(value: T.nilable(T.any(::UserRole, String, Symbol, Integer)))",
      )
    end

    it "generates void return type for setter" do
      output = rbi_for(User)

      setter_lines = output.lines.select { |line| line.include?(".void") }
      expect(setter_lines.length).to eq(4)
    end

    it "generates non-nilable array return type for array enum getter by default" do
      output = rbi_for(User)

      expect(output).to include("returns(T::Array[::UserRecipients])")
      expect(output).not_to include("returns(T.nilable(T::Array[::UserRecipients]))")
    end

    it "generates array parameter type for array enum setter" do
      output = rbi_for(User)

      expect(output).to include(
        "params(value: T.nilable(T::Array[T.any(::UserRecipients, String, Symbol, Integer)]))",
      )
    end
  end
end
