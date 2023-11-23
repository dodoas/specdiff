# Specdiff

A gem for improving diff output in webmock.

Specdiff implements heuristics to diff various datatypes commonly encountered
when writing tests. The goal of this is to improve the legibility of error
messages when said tests inevitably fail.

In other words, I wrote this because I was staring at illegible test output and
thought I could make some improvements.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'specdiff'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install specdiff

## Usage

Put the following in your `spec_helper.rb` (or equivalent initializer for test environment)

```rb
# spec_helper.rb

require "specdiff"
require "specdiff/webmock" # optional, webmock patches
require "specdiff/rspec" # optional, rspec patches
```

## Development

Install the versions specified in `.tool-versions`

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/specdiff.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
