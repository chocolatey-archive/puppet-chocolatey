require 'spec_helper'
require 'puppet/type/chocolateyconfig'

describe Puppet::Type.type(:chocolateyconfig) do
  let(:resource) { Puppet::Type.type(:chocolateyconfig).new(name: 'config', ensure: :absent) }
  let(:provider) { Puppet::Provider.new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }
  let(:minimum_supported_version) { '0.9.10.0' }

  before :each do
    allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version)

    resource.provider = provider
  end

  it 'is an instance of Puppet::Type::Chocolateyconfig' do
    expect(resource).to be_an_instance_of(Puppet::Type::Chocolateyconfig)
  end

  it 'parameter :name should be the name var' do
    expect(resource.parameters[:name]).to be_isnamevar
  end

  # string values
  ['name', 'value'].each do |param|
    context "parameter :#{param}" do
      let(:param_symbol) { param.to_sym }

      it 'does not allow nil' do
        expect {
          resource[param_symbol] = nil
        }.to raise_error(Puppet::Error, %r{Got nil value for #{param}})
      end

      it 'does not allow empty' do
        expect {
          resource[param_symbol] = ''
        }.to raise_error(Puppet::Error, %r{A non-empty #{param} must})
      end

      it 'accepts any string value' do
        resource[param_symbol] = 'value'
        resource[param_symbol] = 'c:/thisstring-location/value/somefile.txt'
        resource[param_symbol] = 'c:\\thisstring-location\\value\\somefile.txt'
      end
    end
  end

  context 'param :ensure' do
    it "accepts 'present'" do
      resource[:ensure] = 'present'
    end

    it 'accepts present' do
      resource[:ensure] = :present
    end

    it 'accepts absent' do
      resource[:ensure] = :absent
    end

    it 'rejects any other value' do
      expect {
        resource[:ensure] = :whenever
      }.to raise_error(Puppet::Error, %r{Invalid value :whenever. Valid values are})
    end
  end

  it 'autorequires Exec[install_chocolatey_official] when in the catalog' do
    exec = Puppet::Type.type(:exec).new(name: 'install_chocolatey_official', path: 'nope')
    catalog.add_resource resource
    catalog.add_resource exec

    reqs = resource.autorequire
    expect(reqs.count).to eq(1)
    expect(reqs[0].source).to eq(exec)
    expect(reqs[0].target).to eq(resource)
  end
end
