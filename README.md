puppet-chocolatey
=====================

[![Build Status](https://travis-ci.org/chocolatey/puppet-chocolatey.png?branch=master)](https://travis-ci.org/chocolatey/puppet-chocolatey)

** Member of the rismoney suite of Windows Puppet Providers **

This is a [Puppet](http://docs.puppetlabs.com/) package provider for
[chocolatey](https://github.com/chocolatey/chocolatey).

Use it like this:

```puppet
class rich::packages {
  $pkg = 'notepadplusplus'

  package { $pkg:
    ensure          => installed,
    provider        => 'chocolatey',
    install_options => '-pre'
  }
}
```

If you want to set this provider as the site-wide default,
add to your `site.pp`:

```puppet
if $::kernel == windows {
  # default package provider
  Package { provider => chocolatey }
}
```

* this is *versionable* so `ensure =>  '1.0'` works
* this is *upgradeable*
* supports `latest` (checks upstream), `absent` (uninstall)
* supports `install_options` for pre-release, other cli


Contributing
------------

See CONTRIBUTING.md at the https://github.com/chocolatey/puppet-chocolatey
