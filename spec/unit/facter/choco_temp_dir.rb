require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'choco_temp_dir fact' do
  subject(:fact) { Facter.fact(:choco_temp_dir) }

  let(:fact_value) { subject.value }

  before(:each) do
    skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
    Facter.clear
    Facter.clear_messages
  end

  it 'returns the TEMP directory' do
    expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:temp_dir).and_return('waffles')

    expect(fact_value).to eq('waffles')
  end
  it 'returns the default path when PuppetX::Chocolatey::ChocolateyInstall.install_path is nil' do
    expect(PuppetX::Chocolatey::ChocolateyInstall).to receieve(:temp_dir).and_return(nil)

    expect(fact_value).to eq(ENV['TEMP'])
  end

  after(:each) do
    Facter.clear
    Facter.clear_messages
  end
end
