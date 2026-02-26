# SorbetModelEnum

Type-safe enums for ActiveRecord models using [Sorbet](https://sorbet.org/)'s `T::Enum`. Bridge `T::Enum` with Rails' `ActiveRecord::Enum` to get full type safety while keeping all of Rails' built-in enum features -- scopes, predicate methods, bang methods, and mapping hashes -- for free.

## Installation

Add to your Gemfile:

```ruby
gem "sorbet-model-enum"
```

## Usage

### Define an enum

```ruby
class UserStatus < T::Enum
  enums do
    Onboarding = new(0)
    Active = new(1)
    Blocked = new(2)
  end
end
```

Each value's serialized form (the integer passed to `new`) is what gets stored in the database.

### Declare the enum on your model

```ruby
class User < ActiveRecord::Base
  sorbet_enum :status, UserStatus
end
```

The underlying column (`:status`) should be an `integer` column in your database.

### Read and write

```ruby
user = User.create!(status: :onboarding)

user.status                          # => UserStatus::Onboarding (T::Enum instance)
user.status == UserStatus::Active    # => false

# Assign a T::Enum instance
user.status = UserStatus::Active

# Assign a symbol (standard Rails)
user.status = :blocked

# Assign a string
user.status = "onboarding"

# Assign nil
user.status = nil
```

### Rails enum features

All standard Rails enum features work out of the box:

```ruby
# Predicate methods
user.onboarding?   # => true
user.active?       # => false

# Bang methods
user.active!       # => update!(status: :active)

# Scopes
User.onboarding    # => ActiveRecord::Relation
User.active        # => ActiveRecord::Relation
User.blocked       # => ActiveRecord::Relation

# Mapping hash
User.statuses      # => {"onboarding"=>0, "active"=>1, "blocked"=>2}
```

### Options passthrough

All Rails `enum` options are supported:

```ruby
class User < ActiveRecord::Base
  sorbet_enum :status, UserStatus, prefix: true
  sorbet_enum :role, UserRole, suffix: :type
end

user.status_onboarding?  # prefix: true
user.admin_type?         # suffix: :type
```

### Multiple enums

A single model can have any number of typed enums:

```ruby
class User < ActiveRecord::Base
  sorbet_enum :status, UserStatus
  sorbet_enum :role, UserRole
end
```

## Sorbet & Tapioca support

The gem ships with a custom [Tapioca](https://github.com/Shopify/tapioca) DSL compiler that generates RBI files for every `sorbet_enum` declaration. Run:

```sh
bundle exec tapioca dsl
```

This generates typed getter/setter signatures so Sorbet understands the methods:

```rbi
# sorbet/rbi/dsl/user.rbi
# typed: true

class User
  sig { returns(T.nilable(::UserStatus)) }
  def status; end

  sig { params(value: T.nilable(T.any(::UserStatus, String, Symbol, Integer))).void }
  def status=(value); end
end
```

## Rails integration

In a Rails app, `SorbetModelEnum::ModelConcern` is automatically included into `ActiveRecord::Base` via a Railtie. No manual setup required.

Outside of Rails, include the concern manually:

```ruby
ActiveRecord::Base.include(SorbetModelEnum::ModelConcern)
```

## Requirements

- Ruby >= 3.2
- Rails >= 7.0
- [sorbet-runtime](https://github.com/sorbet/sorbet) >= 0.6

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akodkod/sorbet-model-enum. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/akodkod/sorbet-model-enum/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
