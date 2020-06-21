# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Fixed

- The `|> with_...()` macros didn't work unless the module was `import`:ed

### Added

- Definition of private tagged tuples.

## [v0.4.1] - 2020-05-31

### Fixed

- Some generated docs failed doctest for arity 0
- Some generated docs failed doctest for arity > 1
- Generated docs failed doctest for `nil` tag
- Generated type definition for arity 0 was `{:tag}` instead of `:tag`

## [v0.4.0] - 2020-05-27

### Added

- Support for different arities, forming Sum Arithmetic Data Types.

### Changed

- Total rework of how to specify wrapped types.
- All types are fully statically defined.
- Reverted the `opaque` type generation.
- Deprecate the use of the examples `Tagged.Status` and `Tagged.Outcome`.

### Fixed

- The type requirement on the `of:` keyword was too strict, breaking
  nontrivial type specifications.

## [v0.3.0] - 2020-05-24

### Added

- Generate `defguard` macros.
- Option to declare the wrapped type statically.

### Changed

- Generated typedefs are `opaque`.

## [v0.2.0] - 2020-05-22

### Added

- Selective function execution in pipes.

### Changed

- Option keywords are now validated on both module and macro level.

### Fixed

- Module level `use` options was not properly unwrapped.
- Generated constructor doc examples referenced the wrong module.
- Code formatting was not configured to keep `deftagged` without parenthesis.

## [v0.1.0] - 2020-05-19

Initial package release.

### Added

- Define `deftagged` macro, used to declare a tagged value tuple.
- Generate a constructor / destructuring macro for a tag.
- Generate a typedef for a tag.

[Unreleased]: https://github.com/notCalle/elixir-tagged/compare/v0.4.1..HEAD
[v0.4.1]: https://github.com/notCalle/elixir-tagged/releases/tag/v0.4.1
[v0.4.0]: https://github.com/notCalle/elixir-tagged/releases/tag/v0.4.0
[v0.3.0]: https://github.com/notCalle/elixir-tagged/releases/tag/v0.3.0
[v0.2.0]: https://github.com/notCalle/elixir-tagged/releases/tag/v0.2.0
[v0.1.0]: https://github.com/notCalle/elixir-tagged/releases/tag/v0.1.0
