# SyntaxTree::RBS

[![Build Status](https://github.com/ruby-syntax-tree/syntax_tree-rbs/actions/workflows/main.yml/badge.svg)](https://github.com/ruby-syntax-tree/syntax_tree-rbs/actions/workflows/main.yml)
[![Gem Version](https://img.shields.io/gem/v/syntax_tree-rbs.svg)](https://rubygems.org/gems/syntax_tree-rbs)

[Syntax Tree](https://github.com/ruby-syntax-tree/syntax_tree) support for RBS.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "syntax_tree-rbs"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install syntax_tree-rbs

## Usage

From code:

```ruby
require "syntax_tree/rbs"

pp SyntaxTree::RBS.parse(source) # print out the AST
puts SyntaxTree::RBS.format(source) # format the AST
```

From the CLI:

```sh
$ stree ast --plugins=rbs file.rbs
(root declarations=[(constant name=(type-name "Hello") type=(class-instance (type-name "World")))])
```

or

```sh
$ stree format --plugins=rbs file.rbs
Hello: World
```

or

```sh
$ stree write --plugins=rbs file.rbs
file.rbs 1ms
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby-syntax-tree/syntax_tree-rbs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
