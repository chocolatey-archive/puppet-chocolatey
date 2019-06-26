require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_version'

describe 'chocolateyversion fact' do
  subject(:fact) { Facter.fact(:chocolateyversion) }

  let(:fact_value) { subject.value }

  before(:each) do
    skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
    Facter.clear
    Facter.clear_messages
  end

  context 'on Windows' do
    it 'returns the output of PuppetX::Chocolatey::ChocolateyVersion.version' do
      allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return('1.2.3')

      expect(fact_value).to eq('1.2.3')
    end

    it 'returns the default of 0 when PuppetX::Chocolatey::ChocolateyVersion.version is nil' do
      allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(nil)

      expect(fact_value).to eq('0')
    end
  end

  after(:each) do
    Facter.clear
    Facter.clear_messages
  end
end
