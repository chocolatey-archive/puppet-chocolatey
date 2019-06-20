require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'choco_install_path fact' do
  subject(:fact) { Facter.fact(:choco_install_path) }

  let(:fact_value) { subject.value }

  before :each do
    skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
    Facter.clear
    Facter.clear_messages
  end

  context 'on Windows' do
    it 'returns the output of PuppetX::Chocolatey::ChocolateyInstall.install_path' do
      expected_value = 'C:\somewhere'
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(expected_value)

      fact_value.must == expected_value
    end

    it 'returns the default path when PuppetX::Chocolatey::ChocolateyInstall.install_path is nil' do
      PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns(nil)

      fact_value.must == 'C:\ProgramData\chocolatey'
    end
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
