require 'spec_helper'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'Chocolatey Install Location' do

  context 'on Windows', :if => Puppet::Util::Platform.windows? do

    it "should return install path from registry if it exists" do
      expected_value = 'C:\somewhere'
      Win32::Registry.any_instance.expects(:[]).with('ChocolateyInstall').returns(expected_value)

      PuppetX::Chocolatey::ChocolateyInstall.install_path.must == expected_value
    end

    it "should return the environment variable ChocolateyInstall if it exists" do
      Win32::Registry.any_instance.expects(:[]).with('ChocolateyInstall').raises(Win32::Registry::Error.new(2), 'file not found yo')

      # this is a placeholder, it is already set in spec_helper
      ENV['ChocolateyInstall'] = 'c:\blah'

      PuppetX::Chocolatey::ChocolateyInstall.install_path.must == 'c:\blah'
    end

    it "should return nil if the environment variable does not exist" do
      Win32::Registry.any_instance.expects(:[]).with('ChocolateyInstall').raises(Win32::Registry::Error.new(2), 'file not found yo')
      ENV['ChocolateyInstall'] = nil

      PuppetX::Chocolatey::ChocolateyInstall.install_path.must be_nil
    end
  end

  context 'on Linux', :if => Puppet.features.posix? do
    it "should return the environment variable ChocolateyInstall if it exists" do
      # this is a placeholder, it is already set in spec_helper
      ENV['ChocolateyInstall'] = 'c:\blah'

      PuppetX::Chocolatey::ChocolateyInstall.install_path.must == 'c:\blah'
    end

    it "should return nil if the ChocolateyInstall variable does not exist" do
      ENV['ChocolateyInstall'] = nil

      PuppetX::Chocolatey::ChocolateyInstall.install_path.must be_nil
    end
  end

  after :each do
    # setting the values back
    ENV['ChocolateyInstall'] = 'c:\blah'
  end

end

describe 'Chocolatey Temp Directory' do
  it "should return the TEMP path from registry if it exists" do
    skip ('Not on Windows platform') unless Puppet::Util::Platform.windows?
    expected_value = 'C:\somewhere'
    Win32::Registry.any_instance.expects(:[]).with('TEMP').returns(expected_value)

    PuppetX::Chocolatey::ChocolateyInstall.temp_dir.must == expected_value
  end
  it "should return nil path from registry if it does not exist" do
    skip ('Not on Windows platform') unless Puppet::Util::Platform.windows?
    Win32::Registry.any_instance.expects(:[]).with('TEMP').raises(Win32::Registry::Error.new(2), 'file not found yo').twice

    PuppetX::Chocolatey::ChocolateyInstall.temp_dir.must be_nil
  end
end
