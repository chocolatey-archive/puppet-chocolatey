puppet-chocolatey
=====================

[![Build Status](https://travis-ci.org/rismoney/puppet-chocolatey.png?branch=master)](https://travis-ci.org/rismoney/puppet-chocolatey)

** Member of the rismoney suite of Windows Puppet Providers **

This is a chocolatey package provider.  

Use it like this:

    class rich::packages {
      $pkg = 'notepadplusplus'

      package { $pkg:
        ensure          => installed,
        provider        => 'chocolatey',
        install_options => '-pre'
      }
    }

* this is now versionable so ensure =>  '1.0' will work
* this is upgradeable 
* supports latest (checks upstream), absent (uninstall)
* supports install_options for pre-release, other cli





