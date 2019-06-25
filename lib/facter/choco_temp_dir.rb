require 'pathname'
require Pathname.new(__FILE__).dirname + '../' + 'puppet_x/chocolatey/chocolatey_install'

Facter.add('choco_temp_dir') do
  confine osfamily: :windows
  setcode do
    PuppetX::Chocolatey::ChocolateyInstall.temp_dir || ENV['TEMP']
  end
end
