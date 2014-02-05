# vim: set ts=2 sw=2 ai et syntax=ruby:
source 'https://rubygems.org'

def location_for(place, fake_version = nil)
  if place =~ /^(git:[^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

puppet_version = ['>= 2.7']
if ENV.key?('PUPPET_VERSION')
  puppet_version = "= #{ENV['PUPPET_VERSION']}"
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
gem "puppet", *location_for(ENV['PUPPET_LOCATION'] || puppet_version)
gem "facter", *location_for(ENV['FACTER_LOCATION'] || '~> 1.6')
gem "hiera", *location_for(ENV['HIERA_LOCATION'] || '~> 1.0')

# see http://projects.puppetlabs.com/issues/21698
platforms :mswin, :mingw do
  gem "sys-admin", "~> 1.5.6", :require => false
  gem "win32-api", "~> 1.4.8", :require => false
  gem "win32-dir", "~> 0.3.7", :require => false
  gem "win32-eventlog", "~> 0.5.3", :require => false
  gem "win32-process", "~> 0.6.5", :require => false
  gem "win32-security", "~> 0.1.4", :require => false
  gem "win32-service", "~> 0.7.2", :require => false
  gem "win32-taskscheduler", "~> 0.2.2", :require => false
  gem "win32console", "~> 1.3.2", :require => false
  gem "windows-api", "~> 0.4.2", :require => false
  gem "windows-pr", "~> 1.2.1", :require => false
  gem "minitar", "~> 0.5.4", :require => false
end

# https://github.com/jumanjiman/jumanjiman_spec_helper
gem 'jumanjiman_spec_helper'

# https://github.com/travis-ci/travis
gem 'travis'

# http://about.travis-ci.org/docs/user/travis-lint/
# https://github.com/travis-ci/travis-lint
gem 'travis-lint'


if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
