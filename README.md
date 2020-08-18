# chocolatey

[![Build Status](https://api.travis-ci.org/puppetlabs/puppetlabs-chocolatey.png?branch=)](https://travis-ci.org/puppetlabs/puppetlabs-chocolatey) [![Build status](https://ci.appveyor.com/api/projects/status/uosorvcyhnayv70m/branch/main?svg=true)](https://ci.appveyor.com/project/puppetlabs/puppetlabs-chocolatey/branch/main)

### Chocolatey for Business Now Available!

We're excited for you to learn more about what's available in the [Business editions](https://chocolatey.org/compare)!

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the chocolatey module does and why it is useful](#module-description)
    * [Why Chocolatey](#why-chocolatey)
3. [Setup - The basics of getting started with chocolatey](#setup)
    * [What chocolatey affects](#what-chocolatey-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Chocolatey provider](#beginning-with-chocolatey-provider)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference](#reference)
    * [Facts](#facts))
6. [Limitations - OS compatibility, etc.](#limitations)
    * [Known Issues](#known-issues)
7. [Development - Guide for contributing to the module](#development)
8. [Attributions](#attributions)

## Overview

This is a [Puppet](http://docs.puppet.com/) package provider for
[Chocolatey](https://github.com/chocolatey/chocolatey), which is
like apt-get, but for Windows. Check the module's metadata.json for
compatible Puppet and Puppet Enterprise versions.

## Module Description

This is the official module for working with the [Chocolatey](https://chocolatey.org/about)
package manager. There are two versions available:

* [puppetlabs/chocolatey](https://forge.puppet.com/puppetlabs/chocolatey)
   * This is the stable version and is commercially supported by Puppet.
   * It is slower moving, but offers greater stability and fewer changes.
* [chocolatey/chocolatey](https://forge.puppet.com/chocolatey/chocolatey)
   * This is the bleeding edge version and is *not commercially supported* by Puppet.
   * It keeps up with all the new features, but is not as fully tested.

This module supports all editions of Chocolatey, including FOSS, [Professional](https://chocolatey.org/compare) and [Chocolatey for Business](https://chocolatey.org/compare).

This module is able to:

* Install Chocolatey
* Work with custom location installations
* Configure Chocolatey
* Use Chocolatey as a package provider

### Why Chocolatey

Chocolatey closely mimics how package managers on other operating systems work. If you can imagine the built-in provider for
Windows versus Chocolatey, take a look at the use case of installing git:

~~~puppet
# Using built-in provider
package { "Git version 1.8.4-preview20130916":
  ensure    => installed,
  source    => 'C:\temp\Git-1.8.4-preview20130916.exe',
  install_options => ['/VERYSILENT']
}
~~~

~~~puppet
# Using Chocolatey (set as default for Windows)
package { 'git':
  ensure   => latest,
}
~~~

With the built-in provider:
 * The [package name must match ***exactly***](https://docs.puppet.com/puppet/latest/reference/resources_package_windows.html#package-name-must-be-the-displayname) the name from installed programs.
 * The package name has issues with unicode characters.
 * The [source must point to the location](https://docs.puppet.com/puppet/latest/reference/resources_package_windows.html#the-source-attribute-is-required) of the executable installer.
 * It cannot `ensure => latest`. Read about [handling versions and upgrades](https://docs.puppet.com/puppet/latest/reference/resources_package_windows.html#handling-versions-and-upgrades) in the Puppet documentation.

With Chocolatey's provider:
 * The package name only has to match the name of the package, which can be whatever you choose.
 * The package knows how to install the software silently.
 * The package knows where to get the executable installer.
 * The source is able to specify different Chocolatey feeds.
 * Chocolatey makes `package` more platform agnostic, because it looks exactly like other platforms.

For reference, read about the [provider features available](https://docs.puppet.com/references/latest/type.html#package-provider-features) from the built-in provider, compared to other package managers:

| Provider   | holdable | install options | installable | package settings | purgeable | reinstallable | uninstall options | uninstallable | upgradeable | versionable | virtual packages |
|------------|----------|-----------------|-------------|------------------|-----------|---------------|-------------------|---------------|-------------|-------------|------------------|
| Windows    |          | x               | x           |                  |           |               | x                 | x             |             | x           |                  |
| Chocolatey | x        | x               | x           |                  |           |               | x                 | x             | x           | x           |                  |
| apt        | x        | x               | x           |                  | x         |               |                   | x             | x           | x           |                  |
| yum        |          | x               | x           |                  | x         |               |                   | x             | x           | x           | x                |

## Setup

### What Chocolatey affects

Chocolatey affects your system and what software is installed on it, ranging
from tools and portable software, to natively installed applications.

### Setup Requirements

Chocolatey requires the following components:

 * Powershell v2+ (Installed on most systems by default)
 * .NET Framework v4+

### Beginning with Chocolatey provider

Install this module via any of these approaches:

* [Puppet Forge](http://forge.puppet.com/chocolatey/chocolatey)
* git-submodule ([tutorial](http://goo.gl/e9aXh))
* [librarian-puppet](https://github.com/rodjek/librarian-puppet)
* [r10k](https://github.com/puppetlabs/r10k)

## Usage

### Manage Chocolatey installation

Ensure Chocolatey is installed and configured:

~~~puppet
include chocolatey
~~~

#### Override default Chocolatey install location

~~~puppet
class {'chocolatey':
  choco_install_location => 'D:\secured\choco',
}
~~~

**NOTE:** This will affect suitability on first install. There are also
special considerations for `C:\Chocolatey` as an install location, see
[`choco_install_location`](#choco_install_location) for details.

#### Use an internal chocolatey.nupkg for Chocolatey installation

~~~puppet
class {'chocolatey':
  chocolatey_download_url         => 'https://internalurl/to/chocolatey.nupkg',
  use_7zip                        => false,
  choco_install_timeout_seconds   => 2700,
}
~~~

#### Use a file chocolatey.0.9.9.9.nupkg for installation

~~~puppet
class {'chocolatey':
  chocolatey_download_url         => 'file:///c:/location/of/chocolatey.0.9.9.9.nupkg',
  use_7zip                        => false,
  choco_install_timeout_seconds   => 2700,
}
~~~

#### Specify the version of chocolatey by class parameters

~~~puppet
class {'chocolatey':
  chocolatey_download_url         => 'file:///c:/location/of/chocolatey.0.9.9.9.nupkg',
  use_7zip                        => false,
  choco_install_timeout_seconds   => 2700,
  chocolatey_version              => '0.9.9.9',
}
~~~


#### Log chocolatey bootstrap installer script output

~~~puppet
class {'chocolatey':
  log_output              => true,
}
~~~

#### Install chocolatey using a proxy server

~~~puppet
class {'chocolatey':
  install_proxy => 'http://proxy.megacorp.com:3128',
}
~~~

### Configuration

If you have Chocolatey 0.9.9.x or above, you can take advantage of configuring different aspects of Chocolatey.

#### Sources Configuration

You can specify sources that Chocolatey uses by default, along with priority.

Requires Chocolatey v0.9.9.0+.

##### Disable the default community repository source

~~~puppet
chocolateysource {'chocolatey':
  ensure => disabled,
}
~~~

##### Set a priority on a source

~~~puppet
chocolateysource {'chocolatey':
  ensure   => present,
  location => 'https://chocolatey.org/api/v2',
  priority => 1,
}
~~~

##### Add credentials to a source

~~~puppet
chocolateysource {'sourcename':
  ensure   => present,
  location => 'https://internal/source',
  user     => 'username',
  password => 'password',
}
~~~

**NOTE:** Chocolatey encrypts the password in a way that is not
verifiable. If you need to rotate passwords, you cannot use this
resource to do so unless you also change the location, user, or priority
(because those are ensurable properties).

#### Features Configuration

You can configure features that Chocolatey has available. Run
`choco feature list` to see the available configuration features.

Requires Chocolatey v0.9.9.0+.

##### Enable Auto Uninstaller

Uninstall from Programs and Features without requiring an explicit
uninstall script.

~~~puppet
chocolateyfeature {'autouninstaller':
  ensure => enabled,
}
~~~

##### Disable Use Package Exit Codes

Requires 0.9.10+ for this feature.

**Use Package Exit Codes** - Allows package scripts to provide exit codes. With
this enabled, Chocolatey uses package exit codes for exit when
non-zero (this value can come from a dependency package). Chocolatey
defines valid exit codes as 0, 1605, 1614, 1641, 3010. With this feature
disabled, Chocolatey exits with a 0 or a 1 (matching previous behavior).

Note that this behavior _may_ cause Puppet to think that the run has failed.
We advise that you leave this at the default setting or disable it. Do _not_ enable it.

~~~puppet
chocolateyfeature {'usepackageexitcodes':
  ensure => disabled,
}
~~~

##### Enable Virus Check

Requires 0.9.10+ and [Chocolatey Pro / Business](https://chocolatey.org/compare)
for this feature.

**Virus Check** - Performs virus checking on downloaded files. *(Licensed versions only.)*

~~~puppet
chocolateyfeature {'viruscheck':
  ensure => enabled,
}
~~~

##### Enable FIPS Compliant Checksums

Requires 0.9.10+ for this feature.

**Use FIPS Compliant Checksums** - Ensures checksumming done by Chocolatey uses
FIPS compliant algorithms. *Not recommended unless required by FIPS Mode.*
Enabling on an existing installation could have unintended consequences
related to upgrades or uninstalls.

~~~puppet
chocolateyfeature {'usefipscompliantchecksums':
  ensure => enabled,
}
~~~

#### Config configuration

You can configure config values that Chocolatey has available. Run
`choco config list` to see the config settings available (just the
config settings section).

Requires Chocolatey v0.9.10.0+.

##### Set cache location

The cache location defaults to the TEMP directory. You can set an explicit directory
to cache downloads to instead of the default.

~~~puppet
chocolateyconfig {'cachelocation':
  value  => "c:\\downloads",
}
~~~

##### Unset cache location

Removes cache location setting, returning the setting to its default.

~~~puppet
chocolateyconfig {'cachelocation':
  ensure => absent,
}
~~~

##### Use an explicit proxy

When using Chocolatey behind a proxy, set `proxy` and optionally
`proxyUser` and `proxyPassword`.

**NOTE:** The `proxyPassword` value is not verifiable.

~~~puppet
chocolateyconfig {'proxy':
  value  => 'https://someproxy.com',
}

chocolateyconfig {'proxyUser':
  value  => 'bob',
}

# not verifiable
chocolateyconfig {'proxyPassword':
  value  => 'securepassword',
}
~~~

#### Set Chocolatey as Default Windows Provider

If you want to set this provider as the site-wide default,
add to your `site.pp`:

~~~puppet
if $::kernel == 'windows' {
  Package { provider => chocolatey, }
}

# OR

case $operatingsystem {
  'windows': {
    Package { provider => chocolatey, }
  }
}
~~~

### Packages

#### With all options

~~~puppet
package { 'notepadplusplus':
  ensure            => installed|latest|'1.0.0'|absent,
  provider          => 'chocolatey',
  install_options   => ['-pre','-params','"','param1','param2','"'],
  uninstall_options => ['-r'],
  source            => 'https://myfeed.example.com/api/v2',
  package_settings  => { 'verbose' => true, 'log_output' => true, },
}
~~~

* Supports `installable` and `uninstallable`.
* Supports `versionable` so that `ensure =>  '1.0'` works.
* Supports `upgradeable`.
* Supports `latest` (checks upstream), `absent` (uninstall).
* Supports `install_options` for pre-release, and other command-line options.
* Supports `uninstall_options` for pre-release, and other command-line options.
* Supports `holdable`, requires Chocolatey v0.9.9.0+.
* Uses package_settings to pass flags to the chocolatey provider.

#### Simple install

~~~puppet
package { 'notepadplusplus':
  ensure   => installed,
  provider => 'chocolatey',
}
~~~

#### To always ensure using the newest version available

~~~puppet
package { 'notepadplusplus':
  ensure   => latest,
  provider => 'chocolatey',
}
~~~

#### To ensure a specific version

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
}
~~~

#### To specify custom source

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
  source   => 'C:\local\folder\packages',
}
~~~

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
  source   => '\\unc\source\packages',
}
~~~

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
  source   => 'https://custom.nuget.odata.feed/api/v2/',
}
~~~

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
  source   => 'C:\local\folder\packages;https://chocolatey.org/api/v2/',
}
~~~

#### Install options with spaces

Spaces in arguments **must always** be covered with a separation. Shown
below is an example of how you configure `-installArgs "/VERYSILENT /NORESTART"`.

~~~puppet
package {'launchy':
  ensure          => installed,
  provider        => 'chocolatey',
  install_options => ['-override', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
}
~~~

#### Install options with quotes or spaces

The underlying installer may need quotes passed to it. This is possible, but not
as intuitive. The example below covers passing `/INSTALLDIR="C:\Program Files\somewhere"`.

For this to be passed through with Chocolatey, you need a set of double
quotes surrounding the argument and two sets of double quotes surrounding the
item that must be quoted (see [how to pass/options/switches](https://github.com/chocolatey/choco/wiki/CommandsReference#how-to-pass-options--switches)). This makes the
string look like `-installArgs "/INSTALLDIR=""C:\Program Files\somewhere"""` for
proper use with Chocolatey.

Then, for Puppet to handle that appropriately, you must split on ***every*** space.
Yes, on **every** space you must split the string or the result comes out
incorrectly. This means it will look like the following:

~~~puppet
install_options => ['-installArgs',
  '"/INSTALLDIR=""C:\Program', 'Files\somewhere"""']
~~~

Make sure you have all of the right quotes - start it off with a single double
quote, then two double quotes, then close it all by closing the two double
quotes and then the single double quote or a possible three double quotes at
the end.

~~~puppet
package {'mysql':
  ensure          => latest,
  provider        => 'chocolatey',
  install_options => ['-override', '-installArgs',
    '"/INSTALLDIR=""C:\Program', 'Files\somewhere"""'],
}
~~~

You can split it up a bit for readability if it suits you:

~~~puppet
package {'mysql':
  ensure          => latest,
  provider        => 'chocolatey',
  install_options => ['-override', '-installArgs', '"'
    '/INSTALLDIR=""C:\Program', 'Files\somewhere""',
    '"'],
}
~~~

**Note:** The above is for Chocolatey v0.9.9+. You may need to look for an
alternative method to pass args if you have 0.9.8.x and below.

#### Passing Flags With Package Settings

You can pass flags to the chocolatey provider using package_settings.  You
might want to do this in a default:

~~~puppet
    Package {
      package_settings => { 'verbose' => true, 'log_output' => true, },
    }
~~~

* "verbose" causes calls to chocolatey to output information about what they're
  *about* to do; this is because some things, in particular "ensure => latest",
  are pretty slow, which can lead to long periods where Puppet appears to be
  doing nothing.
  * When Chocolatey is version `0.10.4` or later and "Verbose" is not specified as `true` Chocolatey will be run with the `--no-progress` parameter, limiting the erroneous output of download information to the logs.
* "log_output" causes the output of chocolatey upgrades and installs to be
  shown.

## Reference

For information on classes and types, see [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-chocolatey/blob/main/REFERENCE.md). For information on facts, see below.

### Facts

* `chocolateyversion` - The version of the installed Chocolatey client (could also be informationally provided by class parameter `chocolatey_version`).
* `choco_install_path` - The location of the installed Chocolatey client (could also be provided by class parameter `choco_install_location`).

## Limitations

* **The module is only suppported on Windows.** For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-chocolatey/blob/main/metadata.json)
* If you override an existing install location of Chocolatey using `choco_install_location =>` in the Chocolatey class, it does not bring any of the existing packages with it. You will need to handle that through some other means.
* Overriding the install location will also not allow Chocolatey to be configured or install packages on the same run that it is installed on. See [`choco_install_location`](#choco_install_location) for details.

### Known Issues

* This module doesn't support side by side scenarios.
* This module may have issues upgrading Chocolatey itself using the package resource.
* If .NET 4.0 is not installed, it may have trouble installing Chocolatey. Chocolatey version 0.9.9.9+ helps alleviate this issue.
* If there is an error in the installer (`InstallChocolatey.ps1.erb`), it may not show as an error. This may be an issue with the PowerShell provider and is still under investigation.

## Development

Acceptance tests for this module leverage [puppet_litmus](https://github.com/puppetlabs/puppet_litmus).
To run the acceptance tests follow the instructions [here](https://github.com/puppetlabs/puppet_litmus/wiki/Tutorial:-use-Litmus-to-execute-acceptance-tests-with-a-sample-module-(MoTD)#install-the-necessary-gems-for-the-module).
You can also find a tutorial and walkthrough of using Litmus and the PDK on [YouTube](https://www.youtube.com/watch?v=FYfR7ZEGHoE).

If you run into an issue with this module, or if you would like to request a feature, please [file a ticket](https://tickets.puppetlabs.com/browse/MODULES/).
Every Monday the Puppet IA Content Team has [office hours](https://puppet.com/community/office-hours) in the [Puppet Community Slack](http://slack.puppet.com/), alternating between an EMEA friendly time (1300 UTC) and an Americas friendly time (0900 Pacific, 1700 UTC).

If you have problems getting this module up and running, please [contact Support](http://puppetlabs.com/services/customer-support).

If you submit a change to this module, be sure to regenerate the reference documentation as follows:

```bash
puppet strings generate --format markdown --out REFERENCE.md
```

## Attributions

A special thanks goes out to [Rich Siegel](https://github.com/rismoney) and [Rob Reynolds](https://github.com/ferventcoder) who wrote the original
provider and continue to contribute to the development of this provider.
