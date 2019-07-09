require 'spec_helper'
require 'puppet/type/chocolateyfeature'

describe Puppet::Type.type(:chocolateyfeature) do
  let(:resource) { Puppet::Type.type(:chocolateyfeature).new(name: 'chocolateyfeature', ensure: 'enabled') }
  let(:provider) { Puppet::Provider.new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }
  let(:minimum_supported_version) { '0.9.9.0' }

  before :each do
    allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version)

    resource.provider = provider
    resource[:ensure] = 'enabled'
  end

  it 'is an instance of Puppet::Type::Chocolateyfeature' do
    expect(resource).to be_an_instance_of(Puppet::Type::Chocolateyfeature)
  end

  it 'parameter :name should be the name var' do
    expect(resource.parameters[:name]).to be_isnamevar
  end

  context 'parameter :name' do
    let(:param_symbol) { :name }

    it 'accepts any string value' do
      resource[param_symbol] = 'value'
      resource[param_symbol] = 'c:/thisstring-location/value/somefile.txt'
      resource[param_symbol] = 'c:\\thisstring-location\\value\\somefile.txt'
    end
  end

  context 'param :ensure' do
    it "accepts 'enabled'" do
      resource[:ensure] = 'enabled'
    end

    it 'accepts enabled' do
      resource[:ensure] = :enabled
    end

    it "accepts 'disabled'" do
      resource[:ensure] = 'disabled'
    end

    it 'accepts :disabled' do
      resource[:ensure] = :disabled
    end

    it 'rejects any other value' do
      expect {
        resource[:ensure] = :whenever
      }.to raise_error(Puppet::Error, %r{Invalid value :whenever. Valid values are})
    end
  end
end
