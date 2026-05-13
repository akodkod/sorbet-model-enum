# frozen_string_literal: true

class User < ActiveRecord::Base
  attribute :recipients, :json

  sorbet_enum :status, UserStatus
  sorbet_enum :role, UserRole
  sorbet_enum :priority, UserPriority, optional: true
  sorbet_enum :recipients, UserRecipients, array: true
end
