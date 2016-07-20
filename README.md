# PrologMinitestMatchers

This is an evolving collection of MiniTest and MiniTest::Spec custom matchers which we have found useful in our work. As we have built up our applications, we've seen the disparity between *tests* and *assertions* grow; often to a differential of 30% or even more. While some standard MiniTest::Spec expectations involve multiple assertions, we can police our own.

For example, we often have class API tests that look something like

```ruby
# in foo.rb
class Foo
  def initialize(foo:, bar:)
    # ...
  end

  # ...
end

# in foo_test.rb

describe 'Foo' do
  describe 'initialisation' do
    describe 'requires parameters for' do
      let(:params) { { foo: 'some foo', bar: 'some bar' } }

      it 'foo' do
        params.delete :foo
        error = expect { Foo.new params }.must_raise ArgumentError
        expect(error.message).must_equal 'missing keyword: foo'
      end

      it 'bar' do
        # ...
      end
    end

    # ... other initialisation tests
  end

  # ... other tests
end

```

That parameter test has two expectations: first, that an `ArgumentError` will be raised; and second, that that error's message will be as expected. Instead, how about this:

```ruby

# in foo_test.rb

describe 'Foo' do
  describe 'initialisation' do
    describe 'requires parameters for' do
      let(:params) { { foo: 'some foo', bar: 'some bar' } }

      it 'foo' do
        expect(Foo).must_require_initialize_parameter params, :foo
      end

      it 'bar' do
        expect(Foo).must_require_initialize_parameter params, :bar
      end
    end

    # ... other initialisation tests
  end

  # ... other tests
end

```

Two expectations; two assertions; two much more *intention-revealing* expectations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'prolog_minitest_matchers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prolog_minitest_matchers

## Usage

See the discussion at the top of this page for a description of how to use the `must_require_initialize_parameter` expectation, which is a MiniTest::Spec wrapper around the `assert_requires_initialize_parameter` MiniTest assertion.

Note that this assertion will verify that the parameter expected to fail when removed must exist in the full set of parameters specified.

As other assertions/expectations are added to this Gem over the next few weeks, *including* formal test coverage of the asserters and expectations themselves, this usage information will be broken out into a separate document. Stay tuned &ndash; or open a pull request!

## Development

After checking out the repo, run `bin/setup` to install dependencies (which as of now must already be installed on your local system). Then, run `bin/rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`. Maintainers should be familiar with the standard procedure for releasing an updated Gem version to RubyGems.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/prolog_minitest_matchers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
