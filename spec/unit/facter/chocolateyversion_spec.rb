require 'spec_helper'
require 'facter'
require 'puppet_x/chocolatey/chocolatey_version'

describe 'chocolateyversion fact' do
  subject(:fact) { Facter.fact(:chocolateyversion) }

  before :each do
    Facter.clear
    Facter.clear_messages
  end

  it "should return the output of PuppetX::Chocolatey::ChocolateyVersion.version" do
    expected_value = '1.2.3'
    PuppetX::Chocolatey::ChocolateyVersion.expects(:version).returns(expected_value)

    subject.value.must == expected_value
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
