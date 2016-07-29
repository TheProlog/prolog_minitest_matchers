# PrologMinitestMatchers

This is an evolving collection of MiniTest and MiniTest::Spec custom matchers which we have found useful in our work. As we have built up our applications, we've seen the disparity between *tests* and *assertions* grow; often to a differential of 30% or even more. While some standard MiniTest::Spec expectations involve multiple assertions, we can police our own.

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

As of Gem Release 0.3.0, this Gem defines three MiniTest::Spec expectations (and thus three MiniTest asserters) that can be used in your MiniTest code:

1. `must_require_dry_struct_attribute` (`assert_requires_dry_struct_attribute`);
2. `must_require_initialize_parameter` (`assert_requires_initialize_parameter`); and
3. `must_require_static_call_param` (`assert_requires_static_call_param`).

In each case, the expectation (through the implementing asserter) will verify that the parameter expected to cause a failure when omitted **must** exist in the supplied set of full parameters.

### `must_require_dry_struct_attribute`

Implemented by asserter `MiniTest::Assertions::AssertRequiresDryStructAttribute`.

Suppose that you have code such as

```ruby
# in foo.rb
class Foo < Dry::Types::Struct
  attribute :foo, Types::Strict::String
  attribute :bar, Types::Coercible.Int
  # ...
end
```

and test code such as

```ruby
# in foo_test.rb

describe 'Foo' do
  describe 'initialisation' do
    describe 'requires parameters for' do
      let(:params) { { foo: 'some foo', bar: 42 } }

      it 'foo' do
        params.delete :foo
        error = expect { Foo.new params }.must_raise KeyError
        expect(error.message).must_equal "No key :foo in #{params.inspect}!"
      end

      it 'bar' do
        # ...
      end
    end # describe 'requires parameters for'
  end # describe 'initialisation'

  # ... other tests
end
```

That parameter test has two expectations: first, that a `KeyError` will be raised; and second, that that error's message will be as expected. Instead, how about this:

```ruby
# in foo_test.rb

describe 'Foo' do
  describe 'initialisation requires parameters for' do
    let(:params) { { foo: 'some foo', bar: 42 } }

    it ':foo' do
      expect(Foo).must_require_dry_struct_attribute params, :foo
    end
    
    it ':bar' do
      expect(Foo).must_require_dry_struct_attribute params, :bar
    end
  end # describe 'initialisation requires parameters for'

  # ... other tests
end
```

Somewhat shorter, yes; more importantly, two much more intention-revealing expectations that are counted as one assertion each. If you ascribe to the widely-used recommendation that each test (`it` block in MiniTest::Spec usage) should test one thing, this will have you wondering "how come my tests and assertions don't match up very well" just that little bit less.

### `must_require_initialize_parameter`

Implemented by asserter `MiniTest::Assertions::AssertRequiresInitializeParameter`.

Again, suppose that you have code such as

```ruby
# in foo.rb
class Foo
  def initialize(foo:, bar:)
    # ...
  end

  # ...
end
```

and test code such as

```ruby
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

As before, that parameter test has two expectations: first, that an `ArgumentError` will be raised; and second, that that error's message will be as expected. Instead, we can now use this:

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

Again, two much more intention-revealing expectations that are counted as one assertion each.

### `must_require_static_call_param`

Implemented by asserter `MiniTest::Assertions::AssertRequiresInitializeParameter`.

This is useful, not for initialisation in the traditional sense, but for service objects implementing a *class-level* `.call` interface that takes one or more named parameters. You might have code that looks like:

```ruby
# in foo.rb
class Foo
  def self.call(foo:, bar:)
    Foo.new(foo, bar).call
  end
  
  def call
    # ...
  end
  
  protected
  
  def initialize(foo, bar)
    @foo = massage_initial_foo_with foo
    @bar = massage_initial_bar_with bar
    self
  end
  
  private
  
  attr_reader :bar, :foo
  # ...
end
```

and test code such as

```ruby
# in foo_test.rb

describe 'Foo' do
  describe 'initialisation' do
    describe 'requires parameters for' do
      let(:params) { { foo: 'some foo', bar: 'some bar' } }

      it 'foo' do
        params.delete :foo
        error = expect { Foo.new params }.must_raise KeyError
        expect(error.message).must_equal "No key :foo in #{params.inspect}!"
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

As before, that parameter test has two expectations: first, that a `KeyError` will be raised; and second, that that error's message will be as expected. We can use this instead:

```ruby
# in foo_test.rb

describe 'Foo' do
  describe 'initialisation' do
    describe 'requires parameters for' do
      let(:params) { { foo: 'some foo', bar: 'some bar' } }

      it 'foo' do
        expect(Foo).must_require_static_call_param params, :foo
      end

      it 'bar' do
        expect(Foo).must_require_static_call_param params, :bar
      end
    end

    # ... other initialisation tests
  end

  # ... other tests
end
```

Once again, two much more intention-revealing expectations that are counted as one assertion each.

### Notes on Implementation

Attentive readers may note the strong similarity between these three expectations. They would be right; although the use cases differ in important ways, the implementation details that set each apart from the others have been reduced to a minimum, as inspecting the code itself will reveal. See some room for improvement? Great! Open an issue and let's talk about it!


## Errata

### Reversing MiniTest::Spec expectations does not work (Issue [#1](https://github.com/TheProlog/prolog_minitest_matchers/issues/1))

Ordinarily, MiniTest::Spec matchers provide reversible expectations; that is, expectations can be positive (`must_`) *or* negative (`won't_`). For a trivial example,

```ruby
expect(2 + 2).must_equal 4
expect(2 + 2).wont_equal 5
```

The same "asserter" code is being exercised, and fails if the asserted condition is false (for `must_equal`) or true (for `wont_equal`).

None of the matchers included as part of Gem Release 0.3.0 (`must_require_dry_struct_attribute`, `must_require_initialize_parameter`, and `must_require_static_call_param`) are reversible in this way. Given the expected use cases of these matchers, this has been judged to be acceptable; the issue has been left open but labelled `wontfix`. (PRs welcome).

## Development

After checking out the repo, run `bin/setup` to install dependencies (which as of now must already be installed on your local system). Then, run `bin/rake test` to run the tests, or `bin/rake` to run tests and, if tests are successful, further static-analysis tools ([RuboCop](https://github.com/bbatsov/rubocop), [Flay](https://github.com/seattlerb/flay), [Flog](https://github.com/seattlerb/flog), and [Reek](https://github.com/troessner/reek)).

To install *your build* of this Gem onto your local machine, run `bin/rake install`. We recommend that you uninstall any previously-installed "official" Gem to increase your confidence that your tests are running against your build.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TheProlog/prolog_minitest_matchers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### Process

If you wish to submit a new feature, such as a new matcher, to the Gem, please [open an issue](https://github.com/TheProlog/prolog_minitest_matchers/issues/new) to discuss your idea with the maintainer and other interested community members. Issue threads are a great place to thrash out the details of what you're trying to accomplish and how your work would affect other code and/or community members. If you need help with something, or aren't sure how to choose between different ideas to accomplish some detail of what you're setting out to do, this is the place to discuss that. There is *no such thing as a stupid question that you don't know the answer to* (once you've researched in your search engine of choice, of course; please do respect people's time and attention).

The processes for proposing a new feature or a fix to an open bug-report issue are very similar:

1. Make sure that you have forked this Gem's [repository on GitHub](https://github.com/TheProlog/prolog_minitest_matchers) to your own GitHub account. (If you don't yet have a GitHub account, [join](https://github.com/join?source=header-home); it's free.)
2. If you're proposing a new feature, [open an issue](https://github.com/TheProlog/prolog_minitest_matchers/issues/new) as suggested above. If you're addressing an existing issue, *thanks;* you don't need to open a new one.
3. Clone *your* copy of the repo to your local development system.
4. Create a new Git branch for your work. It's best to give it a reasonably short name that's suggestive of what you're specifically trying to accomplish.
   1. If you're adding a new feature, such as a new matcher, consider that `dry-struct-attribute` was a more useful branch name for the `must_require_static_call_param` matcher than, say, `my-new-matcher` for (hopefully) obvious reasons.
   2. If you're adding a fix for an existing issue, say Issue #4172, then a branch name of `issue-4172` is probably perfect.
   3. **Do not** work on your copy of the `master` branch! Any pull request (see below) that you later submit for changes you've made on `master` will be rejected, and you will be asked to submit your proposed changes on a branch that branches from a commit on the upstream `master` branch.
5. Now write great (tests and) code!
6. As soon as you have something to show, *even if it's not complete yet* (but it passes what tests you have), [push your branch](https://help.github.com/articles/pushing-to-a-remote/) to *your forked repo* on GitHub and open a [new pull request](https://github.com/TheProlog/prolog_minitest_matchers/compare) ("PR") for *your branch* compared to `master` on the [upstream](https://github.com/TheProlog/prolog_minitest_matchers/) repository. That lets the maintainer and other community members review your code and tests, comment, help out, and so on.
7. Continuing with your pull requests, it's usually better if you make small, incremental changes in each commit in a sequence. We (endeavour to) practice [behaviour-driven development](https://en.wikipedia.org/wiki/Behavior-driven_development): write tests for the simplest thing that could possibly work; see the tests fail; then make them pass, commit, and go on to the next simplest thing. Don't get hung up on lots of refactoring until you have code that does everything you want it to do; once you have a legitimately complete green bar, *that's* the time to apply SOLID principles and patterns to DRY things up. Better to have (temporary) duplication than choose the wrong abstraction.

### Notes on Contributing

Don't be discouraged if it takes several commits to complete your work and then several more to get everybody agreeing that it's complete and well done. ("Useful" and "worth adding" should have been settled at the issue stage, before you started working on your PR.) That's because…

When pull requests are *merged* into the `master` branch, they are *squashed* so that all changes are applied to `master` in a single commit. This means that, even if you have a dozen or more commits in your PR where you've been *very* incremental, and even changed direction once or twice, what matters is the final result; not what it took to get there.

Once your PR has been merged, it's a good idea to pull the upstream `master` branch to your development system (`git pull upstream master`) and then push it to your fork (`git push origin master`). (What? You don't *have* an `upstream` remote as shown by `git remote -v`? Run the command `git remote add upstream https://github.com/TheProlog/prolog_minitest_matchers.git` from your local development directory, and now you do.)

## License

The Gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
