require 'pathname'
require Pathname.new(__FILE__).dirname + '../' + 'puppet_x/chocolatey/chocolatey_version'

Facter.add('chocolateyversion') do
  confine osfamily: :windows
  setcode do
    choco_ver = PuppetX::Chocolatey::ChocolateyVersion.version || '0'
    choco_ver.to_s
  end
end
