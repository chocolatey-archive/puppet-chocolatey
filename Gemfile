# vim: set ts=2 sw=2 ai et syntax=ruby:
source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppet_version = "= #{ENV['PUPPET_VERSION']}"
else
  puppet_version = ['>= 2.7']
end

# https://github.com/jimweirich/rake
gem 'rake', '~> 10.0'

# https://github.com/rspec/rspec
# https://www.relishapp.com/rspec/rspec-core/v/2-0/docs
gem 'rspec'
gem 'rspec-core'
gem 'rspec-expectations'
gem 'rspec-mocks'
gem 'minitest', '~> 5.0.0'

# https://github.com/freerange/mocha#bundler
gem 'mocha', :require => false

# https://github.com/puppetlabs/puppet
gem 'puppet', puppet_version

# https://github.com/jumanjiman/jumanjiman_spec_helper
gem 'jumanjiman_spec_helper'

# https://github.com/travis-ci/travis
gem 'travis'

# http://about.travis-ci.org/docs/user/travis-lint/
# https://github.com/travis-ci/travis-lint
gem 'travis-lint'
