# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2023-03-07

### Added

- Support for RBS 3.

### Changed

- The `visit_alias_declaration` method has been renamed to `visit_type_alias` to better reflect RBS 3.
- The `visit_alias_member` method has been renamed to `visit_alias` to better reflect RBS 3.

## [0.5.1] - 2022-09-03

### Added

- Ruby 2.7.0 is now supported, not just 2.7.3 and above. This allows usage on Ubuntu 20.04 by default.

## [0.5.0] - 2022-07-07

### Added

- A new `SyntaxTree::RBS::Visitor` class that can be used to walk the tree. All `RBS` nodes now respond to `accept(visitor)` which will delegate to the appropriate methods.

### Changed

- Ensure optional proc types have parentheses around them.

## [0.4.0] - 2022-05-13

### Added

- Add an optional `maxwidth` second argument to `SyntaxTree::RBS.format`.

## [0.3.0] - 2022-05-13

### Changed

- Use the `prettier_print` gem for formatting instead of `prettyprint`.

## [0.2.0] - 2022-04-22

### Added

- Support for RBS 1.0 in addition to RBS 2.0.
- Adding support back for Ruby 2.7.
- Support for inline visibility modifiers in RBS 2.0.

## [0.1.0] - 2022-04-05

### Added

- 🎉 Initial release! 🎉

[unreleased]: https://github.com/ruby-syntax-tree/syntax_tree-rbs/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ruby-syntax-tree/syntax_tree-rbs/compare/v0.5.1...v1.0.0
[0.5.1]: https://github.com/ruby-syntax-tree/syntax_tree-rbs/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/ruby-syntax-tree/syntax_tree-rbs/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/ruby-syntax-tree/syntax_tree-rbs/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/ruby-syntax-tree/syntax_tree-rbs/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/ruby-syntax-tree/syntax_tree-rbs/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ruby-syntax-tree/syntax_tree-rbs/compare/93efc7...v0.1.0
