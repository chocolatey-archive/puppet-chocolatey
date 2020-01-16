# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v5.0.2](https://github.com/puppetlabs/puppetlabs-chocolatey/tree/v5.0.2) (2020-01-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-chocolatey/compare/v5.0.1...v5.0.2)

### Fixed

- MODULES-10387 - update dependencies [\#198](https://github.com/puppetlabs/puppetlabs-chocolatey/pull/198) ([lionce](https://github.com/lionce))

## [v5.0.1](https://github.com/puppetlabs/puppetlabs-chocolatey/tree/v5.0.1) (2019-12-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-chocolatey/compare/v5.0.0...v5.0.1)

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-chocolatey/tree/v5.0.0) (2019-10-14)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-chocolatey/compare/v4.1.0...v5.0.0)

### Changed

- Use datatypes and facts hash. Remove logic for Puppet 3.x [\#175](https://github.com/puppetlabs/puppetlabs-chocolatey/pull/175) ([treydock](https://github.com/treydock))

### Fixed

- \(MODULES-8521\) Fix $chocolatey\_version parameter [\#103](https://github.com/puppetlabs/puppetlabs-chocolatey/pull/103) ([helge000](https://github.com/helge000))

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-chocolatey/tree/v4.1.0) (2019-08-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-chocolatey/compare/v4.0.0...v4.1.0)

### Added

- \(MODULES-9690\) Redact Sensitive Commandline [\#168](https://github.com/puppetlabs/puppetlabs-chocolatey/pull/168) ([RandomNoun7](https://github.com/RandomNoun7))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-chocolatey/tree/v4.0.0) (2019-07-30)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-chocolatey/compare/3.3.0...v4.0.0)

### Changed

- \(MODULES-9310\) Raise lower Puppet bound to 5.5.10 [\#159](https://github.com/puppetlabs/puppetlabs-chocolatey/pull/159) ([eimlav](https://github.com/eimlav))

### Added

- \(MODULES-9317\) Add Puppet Strings docs [\#162](https://github.com/puppetlabs/puppetlabs-chocolatey/pull/162) ([eimlav](https://github.com/eimlav))
- \(FM-8194\) Convert tests to litmus [\#156](https://github.com/puppetlabs/puppetlabs-chocolatey/pull/156) ([eimlav](https://github.com/eimlav))
- \(MODULES-9224\) Add no progress flag [\#154](https://github.com/puppetlabs/puppetlabs-chocolatey/pull/154) ([michaeltlombardi](https://github.com/michaeltlombardi))

## 3.3.0

### Added

- Warning note to package parameter documentation for `install_options` to clarify best practices for secrets management with this parameter ([MODULES-8491](https://tickets.puppetlabs.com/browse/MODULES-8491)).
- Parameter `seven_zip_download_url` to make the source of the 7zip binary configurable, allowing the use of this module when the previously hardcoded URL cannot be reached ([MODULES-6652](https://tickets.puppetlabs.com/browse/MODULES-6652)). Thanks, [Daniel Helgenberger](https://github.com/helge000)!

### Fixed

- Ensure that `puppet resource chocolateyconfig` runs without erroring ([MODULES-8047].(https://tickets.puppetlabs.com/browse/MODULES-8047)).

## [3.2.0] - 2019-02-19

### Added

- Configuration option for `chocolateysource` to allow bypassing any system-configured proxies ([MODULES-4418](https://tickets.puppetlabs.com/browse/MODULES-4418)).
- Configuration option for `chocolateysource` to make a source visible only to Windows users in the Administrators group ([MODULES-5898](https://tickets.puppetlabs.com/browse/MODULES-5898)).
- Configuration option for `chocolateysource` to make a source usable with Chocolatey Self Service ([MODULES-5897](https://tickets.puppetlabs.com/browse/MODULES-5897))
- Install Chocolatey from behind a proxy. ([MODULES-5654](https://tickets.puppetlabs.com/browse/MODULES-5654)) Thanks, [Geoff Williams](https://github.com/GeoffWilliams)

### Fixed

- Ensure the `source` syntax in the provider is correct ([MODULES-8493](https://tickets.puppetlabs.com/browse/MODULES-8493)). Thanks, [@jcwest](https://github.com/jcwest)!
- Ensure that if `usePackageExitCodes` is explicitly set to `true` in the Chocolatey configuration then it is observed ([MODULES-5383](https://tickets.puppetlabs.com/browse/MODULES-5383)). Thanks, [David Wood](https://github.com/davidtwco)!
- Only initialize constant when not defined. ([MODULES-7068](https://tickets.puppetlabs.com/browse/MODULES-7068)). Thanks, [Bas Toonk](https://github.com/btoonk)!
- Fix collision in type generation ([MODULES-6948](https://tickets.puppetlabs.com/browse/MODULES-6948)). Thanks [Rico Spiess](https://github.com/rico89)!

## [3.1.1] - 2018-12-10

### Changed

- Changelog converted to KAC format

### Fixed

- Already Initialized Constant Warning ([MODULES-5859](https://tickets.puppetlabs.com/browse/MODULES-5859)). Thanks Paul Reed ([@psreed](https://github.com/psreed))

## [3.1.0] - 2018-10-10

### Fixed

- Choco version rendering error ([MODULES-5788](https://tickets.puppetlabs.com/browse/MODULES-5788))
- Convert tests to rspec format ([MODULES-6746](https://tickets.puppetlabs.com/browse/MODULES-6746))

### Added

- Add support for Puppet 5 ([MODULES-5144](https://tickets.puppetlabs.com/browse/MODULES-5144))
- Add support for Server 2016 ([MODULES-4271](https://tickets.puppetlabs.com/browse/MODULES-4271))
- Add support for Puppet 6 ([MODULES-7832](https://tickets.puppetlabs.com/browse/MODULES-7832))
- Add Beaker Testmode Switcher ([MODULES-6734](https://tickets.puppetlabs.com/browse/MODULES-6734))

### Changed

- Convert module for PDK ([MODULES-7398](https://tickets.puppetlabs.com/browse/MODULES-7398))
- Update Stdlib to 6.0.0 ([MODULES-7705](https://tickets.puppetlabs.com/browse/MODULES-7705))

## [3.0.0] - 2017-06-02

### Fixed

- Explicitly close configuration files after reading ([MODULES-4678](https://tickets.puppetlabs.com/browse/MODULES-4678))
- Use actual choco.exe instead of the shim ([MODULES-4562](https://tickets.puppetlabs.com/browse/MODULES-4562))
- Updated Puppet version compatibility for modern Puppet agents ([MODULES-4846](https://tickets.puppetlabs.com/browse/MODULES-4846))

## [2.0.2] - 2017-04-04

### Fixed

- Use two dashes when getting the package version ([MODULES-4508](https://tickets.puppetlabs.com/browse/MODULES-4508))

## [2.0.1] - 2017-01-03

### Fixed

- ChocolateyInstall environment variable not set for alternate installation directory ([MODULES-4091](https://tickets.puppetlabs.com/browse/MODULES-4091))
- Unsuitable providers should not cause errors ([MODULES-4149](https://tickets.puppetlabs.com/browse/MODULES-4149))
- Version is malformed with any extraneous messages ([MODULES-4135](https://tickets.puppetlabs.com/browse/MODULES-4135))
- Module does not propagate null source error correctly ([MODULES-4056](https://tickets.puppetlabs.com/browse/MODULES-4056))
- Install fails on Windows 10 when using built-in compression ([MODULES-4210](https://tickets.puppetlabs.com/browse/MODULES-4210))

### Added

- Document considerations for install to "C:\Chocolatey" ([MODULES-4090](https://tickets.puppetlabs.com/browse/MODULES-4090))

### Changed

- Set TLS 1.1+ when available

## [2.0.0] - 2016-09-29

### Added

- `chocolateysource` - explicitly require location in ensure ([MODULES-3430](https://tickets.puppet.com/browse/MODULES-3430))
- Supported tag on the forge.

### Changed

- set ignore package exit codes when Chocolatey is on version 0.9.10+ ([MODULES-3880](https://tickets.puppet.com/browse/MODULES-3880))

### Fixed

- Ensure config file exists before `chocolateyfeature`, `chocolateyconfig`, or `chocolateysource` ([MODULES-3677](https://tickets.puppet.com/browse/MODULES-3677))
- `chocolateysource` - ensure flush when disabling source ([MODULES-3430](https://tickets.puppet.com/browse/MODULES-3430))
- `chocolateysource` - erroneous user sync messages ([MODULES-3758](https://tickets.puppet.com/browse/MODULES-3758))

## [0.8.0] - Unsupported 2016-07-13

### Added

- Includes community module releases up to 1.2.6 (changelog below).
- Manage features - `chocolateyfeature` - see [MODULES-3034](https://tickets.puppet.com/browse/MODULES-3034)
- Manage config settings - `chocolateyconfig` - see [MODULES-3035](https://tickets.puppet.com/browse/MODULES-3035)

## [0.7.0] - Unsupported 2016-06-01

### Added

- Manage sources - `chocolateysource` - see [MODULES-3037](https://tickets.puppetlabs.com/browse/MODULES-3037)
- Includes community module releases up to 1.2.1 (changelog below up to 1.2.1)

### Fixed

- `$::chocolateyversion` fact is optional - see [#110](https://github.com/chocolatey/puppet-chocolatey/issues/110)
- puppet apply works again - see [#105](https://github.com/chocolatey/puppet-chocolatey/issues/105)

# Note:
The puppetlabs-chocolatey module replaces the community chocolatey-chocolatey module. We have retained its changelog below as there were a couple of releases where we tracked the puppetlabs-chocolatey modules changes and bug fixes here.

## [1.2.6] - 2016-07-11

### Fixed

- AutoUninstaller runs every time in 0.9.9.x [#134](https://github.com/chocolatey/puppet-chocolatey/issues/134)

## [1.2.5] - 2016-06-20

### Changed

- Support feature list changes in v0.9.10+ [#133](https://github.com/chocolatey/puppet-chocolatey/issues/133)

### Fixed

- Chocolatey fails to install in PowerShell v2 with PowerShell Module 1.x [#128](https://github.com/chocolatey/puppet-chocolatey/issues/128)

## [1.2.4] - 2016-06-04

### Added

- Compatibility with puppetlabs-powershell 2.x [#125](https://github.com/chocolatey/puppet-chocolatey/issues/125).

## [1.2.3] - 2016-05-06

### Added

- Announce [Chocolatey for Business](https://chocolatey.org/compare) in ReadMe.

### Changed

- Do not call choco with --debug --verbose by default [#100](https://github.com/chocolatey/puppet-chocolatey/issues/100).

## [1.2.2] - 2016-04-06

### Changed

- `$::chocolateyversion` fact is optional - see [#110](https://github.com/chocolatey/puppet-chocolatey/issues/110)

### Fixed

- puppet apply works again [#105](https://github.com/chocolatey/puppet-chocolatey/issues/105).
- Implement PowerShell Redirection Fix for Windows 2008 / PowerShell v2 - see [#119](https://github.com/chocolatey/puppet-chocolatey/issues/119)

## [1.2.1] - 2015-12-08

### Added

- Support for newer versions of PE

## [1.2.0] - 2015-11-03

### Added

- holdable ([#95](https://github.com/chocolatey/puppet-chocolatey/issues/95))

### Fixed

- Use install unless the version is specified in install ([#71](https://github.com/chocolatey/puppet-chocolatey/issues/71))

## [1.1.2] - 2015-10-02

### Fixed

- Ensure 0.9.9.9 compatibility ([#94](https://github.com/chocolatey/puppet-chocolatey/issues/94))
- Mixed stale environment variables of existing choco install causing issues ([#86](https://github.com/chocolatey/puppet-chocolatey/issues/86))
- Upgrade From POSH Version of Chocolatey Fails from Puppet ([#60](https://github.com/chocolatey/puppet-chocolatey/issues/60))

## [1.1.1] - 2015-09-25

### Added

- Add log_output for chocolatey bootstrap installer script
- Allow file location for installing nupkg file.

### Changed

- Ensure bootstrap enforces chocolatey.nupkg in libs folder

### [1.1.0] - 2015-09-09

- Install Chocolatey itself / ensure Chocolatey is installed ([PUP-1691](https://tickets.puppetlabs.com/browse/PUP-1691))
- Custom facts for chocolateyversion and choco_install_path

## [1.0.2] - 2015-07-23

### Fixed

- Allow `ensure => $version` to work with already installed packages [#71](https://github.com/chocolatey/puppet-chocolatey/issues/71)

## [1.0.1] - 2015-07-01

### Fixed

- Check for choco existence more comprehensively [#66](https://github.com/chocolatey/puppet-chocolatey/issues/66)

## [1.0.0] - 2015-06-08

## [0.5.3] - 2015-05-22

### Changed

- Update ReadMe - fix/clarify how options with quotes need to be passed.

### Fixed

- Manifest issue
- Choco path issue

## [0.5.2] - 2015-04-23

### Changed

- Readme

### Added

- Support for Windows 10

### Fixed

- Avoiding Puppet returning 2 instead of 0 when there are no changes to be made [#56](https://github.com/chocolatey/puppet-chocolatey/pull/56)

## [0.5.1] - 2015-03-31

### Fixed

- Blocking: Linux masters throw error if the module is present [#54](https://github.com/chocolatey/puppet-chocolatey/issues/54)

## [0.5.0] - 2015-03-30

### Added

- Provider enhancements
- Better docs
- Works with both compiled and powershell Chocolatey clients
- Document best way to pass options with spaces (#15 also related) - [#52](https://github.com/chocolatey/puppet-chocolatey/issues/52)
- Document Chocolatey needs to be installed by other means - [#26](https://github.com/chocolatey/puppet-chocolatey/issues/26)

### Fixed

- work with newer compiled Chocolatey client (0.9.9+) - [#50](https://github.com/chocolatey/puppet-chocolatey/issues/50)
- check for installed packages that are case sensitive - [#43](https://github.com/chocolatey/puppet-chocolatey/issues/43)
- The OS handle's position is not what FileStream expected. - [#18](https://github.com/chocolatey/puppet-chocolatey/issues/18)

## [0.3]

## [0.2]

[Unreleased]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/3.3.0...master
[3.3.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/3.2.0...3.3.0
[3.2.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/3.1.1...3.2.0
[3.1.1]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/3.1.0...3.1.1
[3.1.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/3.0.0...3.1.0
[3.0.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/2.0.2...3.0.0
[2.0.2]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/2.0.1...2.0.2
[2.0.1]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.2.6...2.0.0
[1.2.6]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.2.5...1.2.6
[1.2.5]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.2.4...1.2.5
[1.2.4]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.2.3...1.2.4
[1.2.3]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.2.2...1.2.3
[1.2.2]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.2.1...1.2.2
[1.2.1]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.1.2...1.2.0
[1.1.2]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.0.2...1.1.0
[1.0.2]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.8.0...1.0.0
[0.8.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.7.0...0.8.0
[0.7.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.5.3...0.7.0
[0.5.3]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.5.2...0.5.3
[0.5.2]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.5.1...0.5.2
[0.5.1]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.3...0.4.0
[0.3]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/0.2...0.3
[0.2]: https://github.com/puppetlabs/puppetlabs-chocolatey/compare/af285ea8dbb2b9dd2a08c5374f174cc73ca19e3b...0.2


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
