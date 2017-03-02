Test Levels
===========================

This folder contains tests at the integration and acceptance level for the "puppetlabs-chocolatey" module. The unit 
tests (not included in this folder) are kept in the "spec/unit" level folder of the repository. Acceptance in the 
"tests/acceptance" folder and Integration at the "tests/reference" level.

## Acceptance Folder

At Puppet Inc. we define an "acceptance" test as:

> Validating the system state and/or side effects while completing a stated piece of functionality within a tool.
> This type of test is contained within the boundaries of a tool in order to test a defined functional area within
> that tool.

What this means for this project is that we will install and configure some infrastructure needed for a 
"puppetlabs-chocolatey" environment. (Puppet agent only.)

### configs Folder

The "tests/configs" folder contains Beaker host configuration files for the various test platforms used by the 
test suites. Note: these configs are by default dynamically generated using [Beaker-HostGenerator](https://github.com/puppetlabs/beaker-hostgenerator)
The default config can be overridden by setting the PLATFORM environment variable.

## Integration Folder

These tests were originally written by the QA team at Puppet Labs and is actively maintained by the QA team.
Feel free to contribute tests to this folder.

At Puppet Labs we define an "integration" test as:

> Validating the system state and/or side effects while completing a complete life cycle of user stories using a
> system. This type of test crosses the boundary of a discrete tool in the process of testing a defined user
> objective that utilizes a system composed of integrated components.

What this means for this project is that we will install and configure all infrastructure needed in a real-world
"puppetlabs-chocolatey" environment. (Puppet master and agent.)

## Running Tests

### General Setup Steps:
Option 1 - using Bundler:
1. Install Bundler
```
gem install bundler
```
2. Install dependent gems
```
bundle install --path .bundle/gems
```
3. To see what tasks are available run
```
bundle exec rake -T
```

Option 2 - if not using Bundler, then install the dependent gems.

Puppet's default is to use Bundler, as such the rest of this document will assume use thereof.

### To run integration and reference tests using Rototiller:
Modules frequently have integration tests associated with them that can be run on Puppet's internal network using 
vmpooler with default test setup values set by [Rototiller](https://github.com/puppetlabs/rototiller).
		
Acceptance and reference tests can typically be run with default values using vmpooler inside the network by typing:
```
bundle exec rake acceptance_tests
```
or
```
bundle exec rake reference_tests
```
respectively.

**For vmpooler on the Puppet internal network (only needed for acceptance and integration tests):
To start the the tests you'll need your keyfile setup in one of two ways:
Option 1: Make sure the keyfile is in the default location of ~/.ssh/id_rsa-acceptance
		
Option 2: If your keyfile is in a different directory then override the default by setting the BEAKER_keyfile 
environment variable to where your keyfile is located.

**For Vagrant Cloud
Use the [puppetlabs-packer](https://github.com/puppetlabs/puppetlabs-packer) repository to build images.
