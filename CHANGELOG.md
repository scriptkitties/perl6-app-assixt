# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## [UNRELEASED]
### Added
- `touch` will now add a pod structure at the bottom of `bin`, `lib`, `class`
  and `unit` templates.
- `assixt` has been given a pod document for use with `p6man`.
- New projects will now contain a `CHANGELOG.md` file, based on the
  [Keep a Changelog](https://keepachangelog.com/en/1.0.0) specification.
- `touch meta` has been added to create meta file templates, including a `readme`,
  `gitlab-ci` configuration and `gitignore` files.
- An `undepend` command has been added to remove existing dependencies. Note
  that, like any other module related activity, it is case-sensitive on the
  module names.

### Changed
- `bump` will update other files to show the new version number as well:
  - Files referenced in the `provides` key in `META6.json` will have the
    `=VERSION` blocks updated with the new version.
  - The `CHANGELOG.md` file will have it's `UNRELEASED` block changed to the new
    version number with the current date.
- `bootstrap config` should now work as expected again. Some unnecessary keys
  are new being filtered out, and the save mechanism should work properly now.
- `depend` can now correctly be called with multiple arguments.
- `bump` now uses `Version::Semantic` to deal with the version bumping.
- The directory path check in `new` has been updated to be checked earlier, and
  to give users the option to change the name if needed.

## [0.4.0] - 2018-06-24
### Added
- New projects will now contain a sample GitLab CI configuration

## [0.3.0] - 2018-04-21
### Added
- `api` flag added to META6.json

### Changed
- `author` field now defaults to being an array.
- `assixt test` now calls `run` in sink context, to avoid output of a Failure
  when `prove` found failing tests. [GitHub#7](https://github.com/scriptkitties/perl6-app-assixt/issues/7)

## [0.2.4] - 2018-03-29
### Changed
- Update `Config` dependency to greatly improve performance
- Rewrite Command loading to improve performance
- Tests are now all ran again

## [0.2.3] - 2018-03-23
### Changed
- Slow bin tests are now marked as author tests

## [0.2.2] - 2018-03-21
### Changed
- Tests now show a notice to indicate testing will take a long time

## [0.2.1] - 2018-03-21
### Changed
- Fix a bug which resulted in some commands running twice on a single invocation
- Test suite updated to call the program directly (greatly increases test time, sadly)

## [0.2.0] - 2018-03-20
### Added
- A CHANGELOG is now present to keep track of changes between versions
- USAGE/help can now be invoked using `-h` or `--help` in addition to `help`

### Changed
- Dependency versions are no longer locked to a single version
- The USAGE/help output has been updated to conform to [docopt](http://docopt.org)
- `use` issue resulting in testing bug has been resolved [GitHub#3](https://github.com/scriptkitties/perl6-app-assixt/issues/3)
