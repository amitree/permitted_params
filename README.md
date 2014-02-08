permitted\_params
================

The move from **attr_accessible** to Strong Parameters arguably improved
security by increasing developers' awareness and visibility of which
attributes were whitelisted for mass assignment.  But once you get
beyond toy applications, the standard practice of defining a
`foo_params` method in each `FooController` leads to a lot of duplicated
code, as you find yourself nesting the same structure in many different
places.

The `permitted_params` gem addresses this problem by allowing you to
specify the mass-assignment rules in a single location using a very
simple DSL.

Usage
-----

Add to your Gemfile:

```ruby
gem 'permitted_params'
```

Then create an initializer, `config/initializers/permitted_params.rb`:

```ruby
PermittedParams.setup do |config|
  config.user do
    scalar :username, :password
    scalar :email if action_is(:create)
    scalar :is_admin if current_user.admin?
    array :job_ids
    nested :person
  end

  config.person do
    inherits :thing_with_name
  end

  config.thing_with_name do
    scalar :name
  end
end
```

Now in your controllers, you can simply write:

```ruby
@user = User.create(permitted_params.user)
```

or:

```ruby
user_attributes = { ... some hash ... }
@user = User.create(permitted_params.user(user_attributes))
```

