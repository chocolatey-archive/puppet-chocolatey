require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'choco_install_path fact' do
  subject(:fact) { Facter.fact(:choco_install_path) }

  before :each do
    Facter.clear
    Facter.clear_messages
  end

  it "should return the output of PuppetX::Chocolatey::ChocolateyInstall.install_path" do
    expected_value = 'C:\somewhere'
    PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(expected_value)

    subject.value.must == expected_value
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
