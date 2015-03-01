# Chocolatey Package Provider for Puppet

## Build Status

Travis | AppVeyor
------------- | -------------
[![Build Status](https://travis-ci.org/chocolatey/puppet-chocolatey.png?branch=master)](https://travis-ci.org/chocolatey/puppet-chocolatey) | [![Build status](https://ci.appveyor.com/api/projects/status/8lo0ypk2m931okus/branch/master?svg=true)](https://ci.appveyor.com/project/ferventcoder/puppet-chocolatey/branch/master)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
    * [Why Chocolatey](#why-chocolatey)
3. [Setup - The basics of getting started with Chocolatey](#setup)
    * [What Chocolatey affects](#what-chocolatey-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Chocolatey provider](#beginning-with-chocolatey-provider)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Attributions](#attributions)

## Overview

This is a [Puppet](http://docs.puppetlabs.com/) package provider for
[chocolatey](https://github.com/chocolatey/chocolatey), which is
like apt-get, but for Windows. This should be compatible with a wide
range of Puppet versions.

## Module Description

This is the official module for working with the [Chocolatey](https://chocolatey.org/about)
package manager.

This module will ultimately be able to
* install Chocolatey
* work with custom location installations
* configure Chocolatey
* use Chocolatey as a package provider

### Why Chocolatey

Chocolatey is a nicer abstraction because it nearly mimics how package managers
on other operating systems work. If you can imagine the built in provider for
Windows versus Chocolatey, let's take a look at the use case of installing git:

```puppet
# Using built-in provider
package { "Git version 1.8.4-preview20130916":
  ensure    => installed,
  source    => 'C:\temp\Git-1.8.4-preview20130916.exe',
  install_options => ['/VERYSILENT']
}
```

```puppet
# Using Chocolatey (set as default for Windows)
package { 'git':
  ensure   => latest,
}
```

The built-in provider has the following needs:
 * Package name must match ***exactly*** the name from installed programs. See [package name must be DisplayName](https://docs.puppetlabs.com/puppet/latest/reference/resources_package_windows.html#package-name-must-be-the-displayname)
 * Package name has issues with unicode characters
 * Source must point to the location of the executable installer. See [source is required](https://docs.puppetlabs.com/puppet/latest/reference/resources_package_windows.html#the-source-attribute-is-required).
 * No `ensure => latest` - see [handling versions and upgrades](https://docs.puppetlabs.com/puppet/latest/reference/resources_package_windows.html#handling-versions-and-upgrades)

Chocolatey's provider on the other hand:
 * Package name only has to match the name of the package, which can be whatever you choose.
 * The package is a nice abstraction
 * Package knows how to install the software silently
 * Package knows where to get the executable installer
 * Source is free to specify different Chocolatey feeds
 * Chocolatey makes `package` more platform agnostic since it looks exactly like other platforms.

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

* [puppet forge](http://forge.puppetlabs.com/chocolatey/chocolatey)
* git-submodule ([tutorial](http://goo.gl/e9aXh))
* [librarian-puppet](https://github.com/rodjek/librarian-puppet)
* [r10k](https://github.com/adrienthebo/r10k)

## Usage

Use it like this:

```puppet
package { 'notepadplusplus':
  ensure          => installed,
  provider        => 'chocolatey',
  install_options => ['-pre','-params','-mypkgparam'],
  source          => 'https://myfeed.example.com/api/v2',
}
```

If you want to set this provider as the site-wide default,
add to your `site.pp`:

```puppet
if $::kernel == windows {
  # default package provider
  Package { provider => chocolatey, }
}

# OR

case $operatingsystem {
  'windows':
    Package { provider => chocolatey, }
}
```

* this is *versionable* so `ensure =>  '1.0'` works
* this is *upgradeable*
* supports `latest` (checks upstream), `absent` (uninstall)
* supports `install_options` for pre-release, other cli
* supports 'pinnable'

## Reference

* Chocolatey provider (`lib/puppet/provider/package/chocolatey.rb`)
* params.pp (`manifests/params.pp`)
* install.pp (`manifests/install.pp`)
* config.pp (`manifests/config.pp`)

## Limitations

Works with Windows only.

## Development

See [CONTRIBUTING.md](https://github.com/chocolatey/puppet-chocolatey/blob/master/CONTRIBUTING.md)

## Attributions

A special thanks goes out to [Rich Siegel](https://github.com/rismoney) who wrote the original
provider and continues to contribute to the development of this provider.
