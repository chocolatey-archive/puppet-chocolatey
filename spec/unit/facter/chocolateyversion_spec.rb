require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_version'

describe 'chocolateyversion fact' do
  subject(:fact) { Facter.fact(:chocolateyversion) }

  let(:fact_value) { subject.value }

  before :each do
    skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
    Facter.clear
    Facter.clear_messages
  end

  context 'on Windows' do
    it 'returns the output of PuppetX::Chocolatey::ChocolateyVersion.version' do
      expected_value = '1.2.3'
      PuppetX::Chocolatey::ChocolateyVersion.expects(:version).returns(expected_value)

      fact_value.must == expected_value
    end

    it 'returns the default of 0 when PuppetX::Chocolatey::ChocolateyVersion.version is nil' do
      PuppetX::Chocolatey::ChocolateyVersion.expects(:version).returns(nil)

      fact_value.must == '0'
    end
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
