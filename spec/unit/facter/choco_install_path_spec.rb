require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'choco_install_path fact' do
  subject(:fact) { Facter.fact(:choco_install_path) }

  let(:fact_value) { subject.value }

  before(:each) do
    skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
    Facter.clear
    Facter.clear_messages
  end

  context 'on Windows' do
    it 'returns the output of PuppetX::Chocolatey::ChocolateyInstall.install_path' do
      expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return('C:\somewhere')

      expect(fact_value).to eq('C:\somewhere')
    end

    it 'returns the default path when PuppetX::Chocolatey::ChocolateyInstall.install_path is nil' do
      expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return(nil)

      expect(fact_value).to eq('C:\ProgramData\chocolatey')
    end
  end

  after(:each) do
    Facter.clear
    Facter.clear_messages
  end
end
