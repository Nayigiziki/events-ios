fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Run SwiftLint and SwiftFormat

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests

### ios build

```sh
[bundle exec] fastlane ios build
```

Build for development

### ios unused

```sh
[bundle exec] fastlane ios unused
```

Find unused code

### ios ai_evals

```sh
[bundle exec] fastlane ios ai_evals
```

Run AI calibration evals (requires Claude API)

### ios priority_evals

```sh
[bundle exec] fastlane ios priority_evals
```

Run Priority Stack evals (no API required)

### ios device

```sh
[bundle exec] fastlane ios device
```

Deploy to connected physical device

### ios sync_signing

```sh
[bundle exec] fastlane ios sync_signing
```

Sync certificates and profiles (run once per machine)

### ios renew_certs

```sh
[bundle exec] fastlane ios renew_certs
```

Create new certificates (use when expired)

### ios register_app

```sh
[bundle exec] fastlane ios register_app
```

Register app identifier in Developer Portal

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios beta_quick

```sh
[bundle exec] fastlane ios beta_quick
```

Build and upload to TestFlight (quick - skip processing wait)

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit to App Store Review

### ios version

```sh
[bundle exec] fastlane ios version
```

Print current version and build number

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Bump version number

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
