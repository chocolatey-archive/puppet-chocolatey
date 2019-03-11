require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'choco_temp_dir fact' do
  subject(:fact) { Facter.fact(:choco_temp_dir) }

  before :each do
    Facter.clear
    Facter.clear_messages
  end

  it "should return the TEMP directory" do
    skip ('Not on Windows platform') unless Puppet::Util::Platform.windows?
    expected_value = 'waffles'
    PuppetX::Chocolatey::ChocolateyInstall.expects(:temp_dir).returns(expected_value)

    subject.value.must == expected_value
  end
  it "should return the default path when PuppetX::Chocolatey::ChocolateyInstall.install_path is nil" do
    skip ('Not on Windows platform') unless Puppet::Util::Platform.windows?
    PuppetX::Chocolatey::ChocolateyInstall.expects(:temp_dir).returns(nil)

    subject.value.must == ENV['TEMP']
  end


  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
