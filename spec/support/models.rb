# frozen_string_literal: true

class User < ActiveRecord::Base
  sorbet_enum :status, UserStatus
  sorbet_enum :role, UserRole
end
