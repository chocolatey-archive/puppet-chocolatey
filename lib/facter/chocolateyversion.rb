require 'pathname'
require Pathname.new(__FILE__).dirname + '../' + 'puppet_x/chocolatey/chocolatey_version'

Facter.add('chocolateyversion') do
  setcode do
    PuppetX::Chocolatey::ChocolateyVersion.version
  end
end
