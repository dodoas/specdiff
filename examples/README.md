# Examples

These exist so that I may integration test the gem with the monkey-patches enabled.

But also so that you may see how the gem works in action.

## RSpec

```bash
$ cd examples/rspec
$ bundle install
$ bundle exec rspec
```

## WebMock

```bash
$ cd examples/webmock
$ bundle install

# run separate files for separate examples
$ bundle exec ruby json.rb
$ bundle exec ruby text.rb
```
