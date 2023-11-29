# Specdiff

A gem for improving diff output in webmock.

Webmock currently has a somewhat hidden feature where it will produce a diff
between a request body and a registered stub when making an unregistered request
if they happen to both be json (including setting content type). This gem aims
to bring text diffing (ala rspec) to webmock via monkey-patch, as well as
dropping the content type requirement.

Specdiff automagically detects the types of provided data and prints a suitable
diff between them.

Check out the examples directory to see what it might look like.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "specdiff", require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install specdiff

## Usage

Put the following in your `spec_helper.rb`. (Or equivalent initializer
for test environment) You probably don't want to load/use this gem in a release
environment.

```rb
# spec_helper.rb

require "specdiff"
require "specdiff/webmock" # optional, webmock patches

# optionally, you can turn off terminal colors
Specdiff.configure do |config|
  config.colorize = true
end
```

The webmock patch should make webmock show diffs from the specdiff gem when
stubs mismatch.

### Direct usage

You can also use the gem directly:

```rb
diff = Specdiff.diff(something, and_something_else)

diff.empty? # => true/false, if it is empty you might want to not print the diff, it is probably useless
diff.to_s # => a string for showing to a developer who may or may not be scratching their head
```

## Development

Install the versions specified in `.tool-versions`

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/odinhb/specdiff.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
