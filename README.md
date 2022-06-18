# Crossbeam

Crossbeam is a gem to making it easy to create and run ruby service objects. It allows you to use validations, errors, etc to take away the troubles associated with service classes.

## Installation

Install the gem and add to the application's Gemfile by executing:

```shell
bundle add crossbeam
```

If bundler is not being used to manage dependencies, install the gem by executing:

```shell
gem install crossbeam
```

## Usage

In order to too use the Crossbeam service class you will need to add `include Crossbeam` to the class you wish to make a service object.

### Initializers

You can call and initialize a Crossbeam service call like any other ruby object and 

```ruby
class ServiceClass
  include Crossbeam

  def initialize(name, age, other: nil)
    @age = age
    @name = name
    @other = other
  end

  def call
    do_something
  end

  private

  def do_something
    # .....
  end
end

# Calling the service class
ServiceClass.call('James', 12)
```

Crossbeam also includes [dry-initializer], which allows you to quickly initialize object parameters.
This allows you to bypass having to setup an initialize method in order to assign all attributes to instance variables.

```ruby
class OtherService
  include Crossbeam

  param :name, proc(&:to_s)
  param :age, proc(&:to_i)
  option :other, default: proc { nil }

  def call
    do_something
  end

  private

  def do_something
    # .....
    return "#{@name} is a minor" if @age < 18

    "#{@name} is #{@age}"
  end
end

# Calling the service class
OtherService.call('James', 12)
```

### Output

If you want skip assigning the last attribute returned from call to results you can specify a specific attribute to result reference after `#call` has been ran. This can be done by assigning an attribute to be assigned as the results with `output :attribute_name`.

```ruby
class OutputSample
  include Crossbeam

  param  :name, proc(&:to_s)
  param  :age, default: proc { 10 }

  # Attribute/Instance Variable to return
  output :age

  def call
    @age += 1
    "Hello, #{name}! You are #{age} years old."
  end
end

output = OutputSample.call('James', 12)
output.results
```

### Callbacks

Similar to Rails actions or models Crossbeam allows you to have before/after callbacks for before `call` is ran. They are completely optional and either one can be used without the other. They before/after references can either by a symbol or a block.

```ruby
class SampleClass
  include Crossbeam

  # Callbacks that will be called before/after #call is referenced
  before do
    # setup for #call
  end

  after :cleanup_script

  def call
    # .....
  end

  private

  def cleanup_script
    # .....
  end
end

SampleClass.call
```

### Errors and Validations

#### Errors

```ruby
class ErrorClass
  include Crossbeam

  def initialize(name, age)
    @name = name
    @age = age
  end

  def call
    errors.add(:age, "#{@name} is a minor") if @age < 18
    errors.add(:base, 'something something something')
  end
end

test = ErrorClass.call('James', 10)
test.errors
# => {:age=>["James is a minor"], :base=>["something something something"]}
test.errors.full_messages
# => ["Age James is a minor", "something something something"]
test.errors.to_s
# => Age James is a minor
# => something something something
```

#### Validations

```ruby
require_relative 'crossbeam'

class AgeCheck
  include Crossbeam

  option :age, default: proc { 0 }

  validates :age, numericality: { greater_than_or_equal_to: 18, less_than_or_equal_to: 65 }

  def call
    return 'Minor' unless valid?

    'Adult'
  end
end

puts AgeCheck.call(age: 15).errors.full_messages
# => ["Age must be greater than or equal to 18"]
puts AgeCheck.call(age: 20).results
# => Adult
```

```ruby
require_relative 'crossbeam'

class Bar
  include Crossbeam

  option :age, default: proc { 0 }
  option :drink
  option :description, default: proc { '' }

  validates :age, numericality: { greater_than_or_equal_to: 21, less_than_or_equal_to: 65 }
  validates :drink, inclusion: { in: %w(beer wine whiskey) }
  validates :description, length: { minimum: 7, message: 'is required' }

  def call
    return 'Minor' unless valid?

    'Adult'
  end
end

after_hours = Bar.call(age: 15, drink: 'tanqueray')
puts after_hours.errors.full_messages if after_hours.errors?
# => Age must be greater than or equal to 21
# => Drink is not included in the list
# => Description is required
```

### Fail

If a particular condition is come across you may want to cause a service call to fail. This causes any further action within the service call to not be called and the classes result to be set as nil.

```ruby
class Something
  include Crossbeam

  def call
    fail!('1 is less than 2') unless 1 > 2

    true
  end
end

test = Something.call
test.failure? # => true
puts test.errors.full_messages # => ['1 is less than 2']
test.result # => nil
```

When calling `fail!` you need to supply a message/context very similar to an exception description. And when the service call is forced to fail no results should be returned.

### Generators (Rails)

The Crossbeam service class generator is only available when used with a rails application.

When running the generator you will specify the class name for the service object.

```shell
rails g crossbeam AgeCheck
```

Running this will generate a file `app/services/age_check.rb` with the following contents

```ruby
# frozen_string_literal: true

class AgeCheck
  include Crossbeam

  def call
    # ...
  end
end
```

You can also specify attributes that you want use with the class.

`rails g crossbeam IdentityCheck address age dob name`

```ruby
class IdentityCheck
  include Crossbeam

  option :address
  option :age
  option :dob
  option :name

  def call
    # ...
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tarellel/crossbeam.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

This project is intended to be a safe, welcoming space for collaboration, and everyone interacting in the project’s codebase and issue tracker is expected to adhere to the [Contributor Covenant code of conduct](https://github.com/tarellel/crossbeam/main/CODE_OF_CONDUCT.md).

## Inspired by

* [Actor](https://github.com/sunny/actor)
* [Callee](https://github.com/dreikanter/callee)
* [CivilService](https://github.com/actblue/civil_service)
* [SimpleCommand](https://github.com/nebulab/simple_command)
* [u-case](https://github.com/serradura/u-case)

[dry-initializer]: <https://github.com/dry-rb/dry-initializer>
