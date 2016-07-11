# Chocolatey Package Provider for Puppet

### Chocolatey for Business Now Available!

We're excited for you to learn more about what's available in the [Business editions](https://chocolatey.org/compare)!

## Build Status

Travis | AppVeyor
------------- | -------------
[![Build Status](https://api.travis-ci.org/puppetlabs/puppetlabs-chocolatey.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-chocolatey) | [![Build status](https://ci.appveyor.com/api/projects/status/uosorvcyhnayv70m/branch/master?svg=true)](https://ci.appveyor.com/project/puppetlabs/puppetlabs-chocolatey/branch/master)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
    * [Why Chocolatey](#why-chocolatey)
3. [Setup - The basics of getting started with chocolatey](#setup)
    * [What Chocolatey affects](#what-chocolatey-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Chocolatey provider](#beginning-with-chocolatey-provider)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference](#reference)
    * [Classes](#public-classes)
    * [Facts](#facts)
    * [Types/Providers](#typesproviders)
    * [Package provider: Chocolatey](#package-provider-chocolatey)
    * [Chocolatey source configuration](#chocolateysource)
    * [Chocolatey feature configuration](#chocolateyfeature)
    * [Chocolatey config configuration](#chocolateyconfig)
    * [Class: chocolatey](#class-chocolatey)
6. [Limitations - OS compatibility, etc.](#limitations)
    * [Known Issues](#known-issues)
7. [Development - Guide for contributing to the module](#development)
8. [Attributions](#attributions)

## Overview

This is a [Puppet](http://docs.puppet.com/) package provider for
[chocolatey](https://github.com/chocolatey/chocolatey), which is
like apt-get, but for Windows. This should be compatible with a wide
range of Puppet versions.

## Module Description

This is the official module for working with the [Chocolatey](https://chocolatey.org/about)
package manager.

This module supports all editions of Chocolatey, including FOSS, [Professional](https://chocolatey.org/compare) and [Chocolatey for Business](https://chocolatey.org/compare).

This module will ultimately be able to

* install Chocolatey
* work with custom location installations
* configure Chocolatey
* use Chocolatey as a package provider

### Why Chocolatey

Chocolatey is a nicer abstraction because it nearly mimics how package managers
on other operating systems work. If you can imagine the built in provider for
Windows versus Chocolatey, let's take a look at the use case of installing git:

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

The built-in provider has the following needs:
 * Package name must match ***exactly*** the name from installed programs. See [package name must be DisplayName](https://docs.puppet.com/puppet/latest/reference/resources_package_windows.html#package-name-must-be-the-displayname)
 * Package name has issues with unicode characters
 * Source must point to the location of the executable installer. See [source is required](https://docs.puppet.com/puppet/latest/reference/resources_package_windows.html#the-source-attribute-is-required).
 * No `ensure => latest` - see [handling versions and upgrades](https://docs.puppet.com/puppet/latest/reference/resources_package_windows.html#handling-versions-and-upgrades)

Chocolatey's provider on the other hand:
 * Package name only has to match the name of the package, which can be whatever you choose.
 * The package is a nice abstraction
 * Package knows how to install the software silently
 * Package knows where to get the executable installer
 * Source is free to specify different Chocolatey feeds
 * Chocolatey makes `package` more platform agnostic since it looks exactly like other platforms.

For reference, let's take a look at the [provider features available](https://docs.puppet.com/references/latest/type.html#package-provider-features) as compared to the built-in provider and some other package managers:

<table>
  <thead>
    <tr>
      <th>Provider</th>
      <th>holdable</th>
      <th>install options</th>
      <th>installable</th>
      <th>package settings</th>
      <th>purgeable</th>
      <th>reinstallable</th>
      <th>uninstall options</th>
      <th>uninstallable</th>
      <th>upgradeable</th>
      <th>versionable</th>
      <th>virtual packages</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>windows</td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td> </td>
    </tr>
    <tr>
      <td>chocolatey</td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
    </tr>
    <tr>
      <td>apt</td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
    </tr>
    <tr>
      <td>yum</td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
    </tr>
  </tbody>
</table>

## Setup

### What Chocolatey affects

Chocolatey affects your system and what software is installed on it, ranging
from tools and portable software to natively installed applications.

### Setup Requirements

Chocolatey requires the following components
 * Powershell v2+
   * intalled on most systems by default
 * .NET Framework v4+

### Beginning with Chocolatey provider

Install this module via any of these approaches:

* [puppet forge](http://forge.puppet.com/chocolatey/chocolatey)
* git-submodule ([tutorial](http://goo.gl/e9aXh))
* [librarian-puppet](https://github.com/rodjek/librarian-puppet)
* [r10k](https://github.com/puppetlabs/r10k)

## Usage

### Manage Chocolatey Installation

Ensure Chocolatey is install and configured:

~~~puppet
include chocolatey
~~~

#### Override default Chocolatey install location

~~~puppet
class {'chocolatey':
  choco_install_location => 'D:\secured\choco',
}
~~~

#### Use an internal chocolatey.nupkg for Chocolatey installation

~~~puppet
class {'chocolatey':
  chocolatey_download_url         => 'https://internalurl/to/chocolatey.nupkg',
  use_7zip                        => false,
  choco_install_timeout_seconds   => 2700,
}
~~~

####  Use a file chocolatey.0.9.9.9.nupkg for installation

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

### Set Chocolatey as Default Windows Provider

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

### Configuration

If you have Chocolatey 0.9.9.x and above, you can take advantage of configuring different aspects of Chocolatey.

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
resource to do so unless you also change location, user, or priority (as
those are ensurable properties).

#### Features Configuration
You can configure features that Chocolatey has available. Run
`choco feature list` to see the configuration features available.

Requires Chocolatey v0.9.9.0+.

##### Enable Auto Uninstaller

Uninstall from programs and features without requiring an explicit
uninstall script.

~~~puppet
chocolateyfeature {'autouninstaller':
  ensure => enabled,
}
~~~

##### Disable Use Package Exit Codes

Requires 0.9.10+ for this feature.

Use Package Exit Codes - Package scripts can provide exit codes. With
this on, package exit codes will be what choco uses for exit when
non-zero (this value can come from a dependency package). Chocolatey
defines valid exit codes as 0, 1605, 1614, 1641, 3010. With this feature
off, choco will exit with a 0 or a 1 (matching previous behavior).

~~~puppet
chocolateyfeature {'usepackageexitcodes':
  ensure => disabled,
}
~~~

##### Enable Virus Check

Requires 0.9.10+ and [Chocolatey Pro / Business](https://chocolatey.org/compare)
for this feature.

Virus Check - perform virus checking on downloaded files. Licensed
versions only.

~~~puppet
chocolateyfeature {'viruscheck':
  ensure => enabled,
}
~~~

##### Enable FIPS Compliant Checksums

Requires 0.9.10+ for this feature.

Use FIPS Compliant Checksums - Ensure checksumming done by choco uses
FIPS compliant algorithms. Not recommended unless required by FIPS Mode.
Enabling on an existing installation could have unintended consequences
related to upgrades/uninstalls.

~~~puppet
chocolateyfeature {'usefipscompliantchecksums':
  ensure => enabled,
}
~~~

#### Config Configuration
You can configure config values that Chocolatey has available. Run
`choco config list` to see the config settings available (just the
config settings section).

Requires Chocolatey v0.9.10.0+.

##### Set Cache Location

Cache location defaults to the TEMP directory. Set an explicit directory
to cache downloads to instead of the default.

~~~puppet
chocolateyconfig {'cachelocation':
  value  => "c:\\downloads",
}
~~~

##### Unset Cache Location

Remove cache location setting to go back to default.

~~~puppet
chocolateyconfig {'cachelocation':
  ensure => absent,
}
~~~

##### Use an Explicit Proxy

When using Chocolatey behind a proxy, set `proxy` and optionally
`proxyUser`/`proxyPassword` as well.

**NOTE:** `proxyPassword` value is not verifiable.

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


### Packages

#### With All Options

~~~puppet
package { 'notepadplusplus':
  ensure            => installed|latest|'1.0.0'|absent,
  provider          => 'chocolatey',
  install_options   => ['-pre','-params','"','param1','param2','"'],
  uninstall_options => ['-r'],
  source            => 'https://myfeed.example.com/api/v2',
}
~~~

* supports `installable` and `uninstallable`
* supports `versionable` so `ensure =>  '1.0'` works
* supports `upgradeable`
* supports `latest` (checks upstream), `absent` (uninstall)
* supports `install_options` for pre-release, other cli
* supports `uninstall_options` for pre-release, other cli
* supports `holdable`, requires Chocolatey v0.9.9.0+

#### Simple install

~~~puppet
package { 'notepadplusplus':
  ensure   => installed,
  provider => 'chocolatey',
}
~~~

#### Ensure always the newest version available

~~~puppet
package { 'notepadplusplus':
  ensure   => latest,
  provider => 'chocolatey',
}
~~~

#### Ensure specific version

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
}
~~~

#### Specify custom source

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

Spaces in arguments **must always** be covered with a separation. The example
below covers `-installArgs "/VERYSILENT /NORESTART"`.

~~~puppet
package {'launchy':
  ensure          => installed,
  provider        => 'chocolatey',
  install_options => ['-override', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
}
~~~

#### Install options with quotes / spaces
The underlying installer may need quotes passed to it. This is possible, but not
as intuitive.  The example below covers passing
`/INSTALLDIR="C:\Program Files\somewhere"`.

For this to be passed through with Chocolatey, you will need a set of double
quotes surrounding the argument and two sets of double quotes surrounding the
item that must be quoted (see [how to pass/options/switches](https://github.com/chocolatey/choco/wiki/CommandsReference#how-to-pass-options--switches)). This makes the
string look like `-installArgs "/INSTALLDIR=""C:\Program Files\somewhere"""` for
proper use with Chocolatey.

Then for Puppet to handle that appropriately, we must split on ***every*** space.
Yes, on **every** space we must split the string or the result will come out
incorrectly. So this means it will look like the following:

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

## Reference

### Classes
#### Public classes
* [`chocolatey`](#class-chocolatey)

#### Private classes
* `chocolatey::install.pp`: Ensures Chocolatey is installed.
* `chocolatey::config.pp`: Ensures Chocolatey is configured.

### Facts
* `chocolateyversion` - The version of the installed choco client (could also be provided by class parameter `chocolatey_version`).
* `choco_install_path` - The location of the installed choco client (could also be provided by class parameter `choco_install_location`).

### Types/Providers
* [Chocolatey provider](#package-provider-chocolatey)
* [Chocolatey source configuration](#chocolateysource)
* [Chocolatey feature configuration](#chocolateyfeature)


### Package Provider: Chocolatey
Chocolatey implements a [package type](http://docs.puppet.com/references/latest/type.html#package) with a resource provider, which is built into Puppet.

This provider supports the `install_options` and `uninstall_options` attributes,
which allow command-line options to be passed to the choco command. These options
should be specified as documented below.

 * Required binaries: `choco.exe`, usually found in `C:\Program Data\chocolatey\bin\choco.exe`.
   * The binary is searched for using the Environment Variable `ChocolateyInstall`, then by two known locations (`C:\Chocolatey\bin\choco.exe` and `C:\ProgramData\chocolatey\bin\choco.exe`).
   * On Windows 2003 you should install Chocolatey to `C:\Chocolatey` or somewhere besides the default. **NOTE**: the root of `C:\` is not a secure location by default, so you may want to update the security on the folder.
 * Supported features: `install_options`, `installable`, `uninstall_options`,
`uninstallable`, `upgradeable`, `versionable`.

#### Properties/Parameters

##### `ensure`
(**Property**: This attribute represents concrete state on the target system.)

What state the package should be in. You can choose which package to retrieve by
specifying a version number or `latest` as the ensure value. This defaults to
`installed`.

Valid options: `present` (also called `installed`), `absent`, `latest`,
`held` or a version number.

##### `install_options`
An array of additional options to pass when installing a package. These options are
package-specific, and should be documented by the software vendor. One commonly
implemented option is `INSTALLDIR`:

~~~puppet
package {'launchy':
  ensure          => installed,
  provider        => 'chocolatey',
  install_options => ['-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
}
~~~

The above method of single quotes in an array is the only method you should use
in passing `install_options` with the Chocolatey provider. There are other ways
to do it, but they are passed through to Chocolatey in ways that may not be
sufficient.

This is the **only** place in Puppet where backslash separators should be used.
Note that backslashes in double-quoted strings *must* be double-escaped and
backslashes in single-quoted strings *may* be double-escaped.

##### `name`
(**Namevar**: If ommitted, this attribute's value will default to the resource's
title.)

The package name. This is the name that the packaging system uses internally.

##### `provider`
The specific backend to use for the `package` resource. Chocolatey is not the
default provider for Windows so it must be specified (or by using a resource
default, shown in Usage). Valid options for this provider are `'chocolatey'`.

##### `source`
Where to find the package file. Chocolatey maintains default sources in its
configuration file that it will use by default. Use this to override the default
source(s).

Chocolatey accepts different values for source, including accept paths to local
files/folders stored on the target system, URLs (to OData feeds), and network
drive paths. Puppet will not automatically retrieve source files for you, and
usually just passes the value of source to the package installation command.

You can use a `file` resource if you need to manually copy package files to the
target system.

##### `uninstall_options`
An array of additional options to pass when uninstalling a package. These options
are package-specific, and should be documented by the software vendor.

~~~puppet
package {'launchy':
  ensure          => absent,
  provider        => 'chocolatey',
  uninstall_options => ['-uninstallargs', '"', '/VERYSILENT', '/NORESTART', '"'],
}
~~~

The above method of single quotes in an array is the only method you should use
in passing `uninstall_options` with the Chocolatey provider. There are other ways
to do it, but they are passed through to Chocolatey in ways that may not be
sufficient.

This is the **only** place in Puppet where backslash separators should be used.
Note that backslashes in double-quoted strings *must* be double-escaped and
backslashes in single-quoted strings *may* be double-escaped.


### ChocolateySource
Allows managing default sources for Chocolatey. A source can be a folder, a CIFS share,
a NuGet Http OData feed, or a full Package Gallery. Learn more about sources at
[How To Host Feed](https://chocolatey.org/docs/how-to-host-feed). Requires
Chocolatey v0.9.9.0+.

#### Properties/Parameters

##### `name`
(**Namevar**: If ommitted, this attribute's value will default to the resource's
title.)

The name of the source. Used for uniqueness. Will set the location to this value if location is unset.

##### `ensure`
(**Property**: This attribute represents concrete state on the target system.)

What state the source should be in. This defaults to `present`.

Valid options: `present`, `disabled`, or `absent`.

##### `location`
(**Property**: This attribute represents concrete state on the target system.)

The location of the source repository. Can be a url pointing to an OData feed (like chocolatey/chocolatey_server), a CIFS (UNC) share, or a local folder. Defaults to the name of the resource.

##### `user`
(**Property**: This attribute represents concrete state on the target system.)

Optional user name for authenticated feeds. Requires at least Chocolatey v0.9.9.0. Defaults to `nil`. Specifying an empty value is the same as setting the value to nil or not specifying the property at all.

##### `password`
Optional user password for authenticated feeds. Not ensurable. Value is not able to be checked with current value. If you need to update the password, update another setting as well. Requires at least Chocolatey v0.9.9.0. Defaults to `nil`. Specifying an empty value is the same as setting the value to nil or not specifying the property at all.

##### `priority`
(**Property**: This attribute represents concrete state on the target system.)

Optional priority for explicit feed order when searching for packages across multiple feeds. The lower the number the higher the priority. Sources with a 0 priority are considered no priority and are added after other sources with a priority number. Requires at least Chocolatey v0.9.9.9. Defaults to `0`.

### ChocolateyFeature
Allows managing features for Chocolatey. Features are configuration that
act as feature flippers to turn on or off certain aspects of how
Chocolatey works. Learn more about features at
[Features](https://chocolatey.org/docs/commands-feature). Requires
Chocolatey v0.9.9.0+.

#### Properties/Parameters

##### `name`
(**Namevar**: If ommitted, this attribute's value will default to the resource's
title.)

The name of the feature. Used for uniqueness.

##### `ensure`
(**Property**: This attribute represents concrete state on the target system.)

What state the feature should be in.

Valid options: `enabled` or `disabled`.


### ChocolateyConfig
Allows managing config settings for Chocolatey. Configuration values
provide settings for users to configure aspects of Chocolatey and the
way it functions. Similar to features, except allow for user configured
values. Learn more about config settings at
[Config](https://chocolatey.org/docs/commands-config). Requires
Chocolatey v0.9.9.9+.

#### Properties/Parameters

##### `name`
(**Namevar**: If ommitted, this attribute's value will default to the resource's
title.)

The name of the config setting. Used for uniqueness. Puppet is not able to
easily manage any values that include Password in the key name in them as they
will be encrypted in the configuration file.

##### `ensure`
(**Property**: This attribute represents concrete state on the target system.)

What state the config should be in. This defaults to `present`.

Valid options: `present` or `absent`.

##### `value`
(**Property**: This attribute represents concrete state on the target system.)

The value of the config setting. If the name includes "password", then the value
is not ensurable due to being encrypted in the configuration file.


### Class: chocolatey

Used for managing installation and configuration of Chocolatey itself.

#### Parameters

##### `choco_install_location`

Where Chocolatey install should be located. This needs to be an absolute path starting with a drive letter e.g. `c:\`. Defaults to the currently detected install location based on the `ChocolateyInstall` environment variable, falls back to `'C:\ProgramData\chocolatey'`.

##### `use_7zip`

Whether to use built-in shell or allow installer to download 7zip to extract `chocolatey.nupkg` during installation. Defaults to `true`.

##### `choco_install_timeout_seconds`

How long in seconds should be allowed for the install of Chocolatey (including .NET Framework 4 if necessary). Defaults to `1500` (25 minutes).

##### `chocolatey_download_url`

A url that will return `chocolatey.nupkg`. This must be a url, but not necessarily an OData feed. Any old url location will work. Defaults to `'https://chocolatey.org/api/v2/package/chocolatey/'`.

##### `enable_autouninstaller`

Should auto uninstaller be turned on? Auto uninstaller is what allows Chocolatey to automatically manage the uninstall of software from Programs and Features without necessarily requiring a `chocolateyUninstall.ps1` file in the package. Defaults to `true`.

##### `log_output`

Log output from the installer. Defaults to `false`.


## Limitations

1. Works with Windows only.
2. If you override an existing install location of Chocolatey using `choco_install_location =>` in the Chocolatey class, it does not bring any of the existing packages with it. You will need to handle that through some other means.

### Known Issues

1. This module doesn't support side by side scenarios.
2. This module may have issues upgrading Chocolatey itself using the package resource.
3. If .NET 4.0 is not installed, it may have trouble installing Chocolatey. Chocolatey version 0.9.9.9+ help alleviate this issue.
4. If there is an error in the installer (`InstallChocolatey.ps1.erb`), it may not show as an error. This may be an issue with the PowerShell provider and is still under investigation.

## Development

Puppet Inc modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppet.com/forge/contributing.html)

## Attributions

A special thanks goes out to [Rich Siegel](https://github.com/rismoney) and [Rob Reynolds](https://github.com/ferventcoder) who wrote the original
provider and continues to contribute to the development of this provider.
