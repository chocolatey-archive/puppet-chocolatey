require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'choco_temp_dir fact' do
  subject(:fact) { Facter.fact(:choco_temp_dir) }

  let(:fact_value) { subject.value }

  before :each do
    skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
    Facter.clear
    Facter.clear_messages
  end

  it 'returns the TEMP directory' do
    expected_value = 'waffles'
    PuppetX::Chocolatey::ChocolateyInstall.expects(:temp_dir).returns(expected_value)

    fact_value.must == expected_value
  end
  it 'returns the default path when PuppetX::Chocolatey::ChocolateyInstall.install_path is nil' do
    PuppetX::Chocolatey::ChocolateyInstall.expects(:temp_dir).returns(nil)

    fact_value.must == ENV['TEMP']
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
