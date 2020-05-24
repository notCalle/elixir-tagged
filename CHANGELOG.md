# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[Unreleased]: https://github.com/notCalle/elixir-tagged/compare/v0.3.0..HEAD
[v0.3.0]: https://github.com/notCalle/elixir-tagged/releases/tag/v0.3.0
[v0.2.0]: https://github.com/notCalle/elixir-tagged/releases/tag/v0.2.0
[v0.1.0]: https://github.com/notCalle/elixir-tagged/releases/tag/v0.1.0
