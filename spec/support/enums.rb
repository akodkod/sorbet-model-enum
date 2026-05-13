# frozen_string_literal: true

class UserStatus < T::Enum
  enums do
    Onboarding = new(0)
    Active = new(1)
    Blocked = new(2)
  end
end

class UserRole < T::Enum
  enums do
    Admin = new(0)
    Member = new(1)
    Guest = new(2)
  end
end

class UserRecipients < T::Enum
  enums do
    CompanyAdmins = new("company-admins")
    CompanyMembers = new("company-members")
    OfficeAdmins = new("office-admins")
    OfficeMembers = new("office-members")
  end
end
