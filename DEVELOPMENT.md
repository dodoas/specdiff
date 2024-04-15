# Development

## Glossary

Check out the [glossary](./glossary.txt) to make sure we are using the same
words for things.

## Setup

Install the software versions specified in `.tool-versions`.

Run `bin/setup` to install dependencies. Then, run `bundle exec rake` to run
the tests and linter and make sure they're green
before starting to make your changes.

Run `bundle exec rake -AD` for a full list of all the available tasks you may use for development purposes.

Run `bundle exec rake` to run the tests and linter.

## Examples

The `examples/` directory is used as an ad-hoc integration testing method.
[Read more here](./examples/)

## Pull request checklist

- [ ] Make sure the tests are passing
- [ ] Make sure the linter is happy
- [ ] Make sure the `examples/` look the same or have suffered and improvement
- [ ] Update the unreleased section of the [changelog](./CHANGELOG.md) with a human readable explanation of your changes

## Architecture

High level description of the heuristic specdiff implements

  1. receive 2 pieces of data: `a` and `b`
  2. determine types for `a` and `b`
      1. test against plugin types
      2. test against built in types
      3. fall back to the `:unknown` type
  3. determine which differ is appropriate for the types
      1. test against plugin differs
      2. test against built in differs
      3. fall back to the null differ (`NotFound`)
  7. run the selected differ with a and b
  8. package it into a `::Specdiff::Diff` which records the detected types

  \<time passes>

  6. at some point later when `#to_s` is invoked, stringify the diff using the differ's `#stringify`

## Maintainer's notes

### Release procedure

  - [ ] unit tests are passing (`$ bundle exec rake test`)
  - [ ] linter is happy (`$ bundle exec rake lint`)
  - [ ] `examples/` look good
  - [ ] check the package size using `$ bundle exec inspect_build`, make sure you haven't added any large files by accident
  - [ ] update the version number in `version.rb`
  - [ ] make sure the `examples/` `Gemfile.lock` files are updated (run bundle install)
  - [ ] make sure `Gemfile.lock` is updated (run bundle install)
  - [ ] move unreleased changes to the next version in the [changelog](./CHANGELOG.md)
  - [ ] commit in the form "vX.X.X" and push
  - [ ] make sure the pipeline is green
  - [ ] `$ bundle exec rake release`

### Contemplated improvements (AKA the todo list)

- [ ] word diff
- [ ] yard documentation?
- [ ] 2.7.0 support
- [ ] actual integration tests (replacing `examples/`)
- [ ] real documentation for the plugin interface
