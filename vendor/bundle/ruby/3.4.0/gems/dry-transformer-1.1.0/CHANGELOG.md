# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [Unreleased]

## [1.1.0] - 2025-12-03

### Added

- Fixed using `prefix` option in `Dry::Transformer::HashTransformations.unwrap` in DSL (@flash-gordon)


## [1.0.1] - 2022-11-23


### Fixed

- Auto-loading issues for array transformations (@flash-gordon)


[Compare v1.0.0...v1.0.1](https://github.com/dry-rb/dry-transformer/compare/v1.0.0...v1.0.1)

## [1.0.0] - 2022-11-20


### Changed

- Use Zeitwerk to auto-load the gem (via #14) (@solnic)
- Dropped dependency on dry-core (via #14) (@solnic)

[Compare v0.1.1...v1.0.0](https://github.com/dry-rb/dry-transformer/compare/v0.1.1...v1.0.0)

## [0.1.1] - 2020-01-14


### Fixed

- Fixed Dry::Transformer::HashTransformations.unwrap when hash contains root key (@AMHOL)


[Compare v0.1.0...v0.1.1](https://github.com/dry-rb/dry-transformer/compare/v0.1.0...v0.1.1)

## [0.1.0] - 2019-12-28

Initial port of the [transproc](https://github.com/solnic/transproc) gem.
