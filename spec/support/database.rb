# frozen_string_literal: true

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.include(SorbetModelEnum::ModelConcern)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.integer :status
    t.integer :role
  end
end
