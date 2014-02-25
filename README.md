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

See more details on our blog: [http://thesource.amitree.com/2014/02/protected-attributes.html](http://thesource.amitree.com/2014/02/protected-attributes.html).

This work was inspired by
[RailsCast #371](http://railscasts.com/episodes/371-strong-parameters).
Thanks, [ryanb](https://github.com/ryanb)!

Installation
-----

Add to your Gemfile:

```ruby
gem 'permitted_params'
```

Generate initializer:
```ruby
rails generate permitted_params
```

Or create an initializer manually: `config/initializers/permitted_params.rb`:

```ruby
PermittedParams.setup do |config|
  config.user do
    # We always permit username and password to be mass-assigned
    scalar :username, :password

    # email can be mass-assigned from create (but not from update)
    scalar :email if action_is(:create)

    # Only admins can change the is_admin flag.  Note that we can call
    # any controller methods (including current_user) from this scope.
    scalar :is_admin if current_user.admin?

    # We permit job_ids to be an array of scalar values
    array :job_ids

    # We permit person_attributes containing the whitelisted attributes
    # of person (see definition below)
    nested :person
  end

  config.person do
    # Inheritance!
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

