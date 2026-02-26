# frozen_string_literal: true

RSpec.describe SorbetModelEnum::ModelConcern do
  describe "getter" do
    it "returns a T::Enum instance" do
      user = User.create!(status: :onboarding)

      expect(user.status).to be_a(UserStatus)
      expect(user.status).to eq(UserStatus::Onboarding)
    end

    it "returns nil for nil column" do
      user = User.create!

      expect(user.status).to be_nil
    end

    it "works after reload" do
      user = User.create!(status: :active)
      user.reload

      expect(user.status).to eq(UserStatus::Active)
    end

    it "works after find" do
      user = User.create!(status: :blocked)
      loaded = User.find(user.id)

      expect(loaded.status).to eq(UserStatus::Blocked)
    end

    it "supports equality comparison" do
      user = User.create!(status: :onboarding)

      expect(user.status == UserStatus::Onboarding).to be(true)
      expect(user.status == UserStatus::Active).to be(false)
    end
  end

  describe "setter" do
    it "accepts a T::Enum instance" do
      user = User.new
      user.status = UserStatus::Active
      user.save!

      loaded = User.find(user.id)
      expect(loaded.status).to eq(UserStatus::Active)
    end

    it "accepts a symbol" do
      user = User.new
      user.status = :blocked
      user.save!

      loaded = User.find(user.id)
      expect(loaded.status).to eq(UserStatus::Blocked)
    end

    it "accepts a string" do
      user = User.new
      user.status = "onboarding"
      user.save!

      loaded = User.find(user.id)
      expect(loaded.status).to eq(UserStatus::Onboarding)
    end

    it "accepts an integer" do
      user = User.new
      user.status = 1
      user.save!

      loaded = User.find(user.id)
      expect(loaded.status).to eq(UserStatus::Active)
    end

    it "accepts nil" do
      user = User.create!(status: :active)
      user.status = nil
      user.save!

      loaded = User.find(user.id)
      expect(loaded.status).to be_nil
    end

    it "persists T::Enum value after save and reload" do
      user = User.create!
      user.status = UserStatus::Blocked
      user.save!
      user.reload

      expect(user.status).to eq(UserStatus::Blocked)
    end
  end

  describe "Rails enum delegation" do
    it "provides predicate methods" do
      user = User.create!(status: :onboarding)

      expect(user.onboarding?).to be(true)
      expect(user.active?).to be(false)
      expect(user.blocked?).to be(false)
    end

    it "provides bang methods" do
      user = User.create!(status: :onboarding)
      user.active!

      expect(user.status).to eq(UserStatus::Active)
    end

    it "provides scopes" do
      User.create!(status: :onboarding)
      User.create!(status: :active)
      User.create!(status: :blocked)

      expect(User.onboarding.count).to eq(1)
      expect(User.active.count).to eq(1)
      expect(User.blocked.count).to eq(1)
    end

    it "provides mapping hash" do
      expect(User.statuses).to eq({ "onboarding" => 0, "active" => 1, "blocked" => 2 })
    end
  end

  describe "multiple enums" do
    it "supports independent enums on the same model" do
      user = User.create!(status: :active, role: :admin)

      expect(user.status).to eq(UserStatus::Active)
      expect(user.role).to eq(UserRole::Admin)
    end
  end

  describe "options passthrough" do
    context "with prefix option" do
      before do
        # Create a temporary model to test prefix option
        stub_const("PrefixUser", Class.new(ActiveRecord::Base) do
          self.table_name = "users"
          sorbet_enum :status, UserStatus, prefix: true
        end)
      end

      it "prefixes predicate methods" do
        user = PrefixUser.create!(status: :onboarding)

        expect(user.status_onboarding?).to be(true)
      end
    end

    context "with suffix option" do
      before do
        stub_const("SuffixUser", Class.new(ActiveRecord::Base) do
          self.table_name = "users"
          sorbet_enum :status, UserStatus, suffix: :type
        end)
      end

      it "suffixes predicate methods" do
        user = SuffixUser.create!(status: :onboarding)

        expect(user.onboarding_type?).to be(true)
      end
    end
  end

  describe "validation" do
    it "raises ArgumentError if enum_class is not a T::Enum subclass" do
      expect do
        Class.new(ActiveRecord::Base) do
          self.table_name = "users"
          sorbet_enum :status, String
        end
      end.to raise_error(ArgumentError, /must be a T::Enum subclass/)
    end
  end
end
