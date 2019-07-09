require 'spec_helper'
require 'puppet/type/chocolateysource'

describe Puppet::Type.type(:chocolateysource) do
  let(:resource) { Puppet::Type.type(:chocolateysource).new(name: 'source', location: 'c:\packages') }
  let(:provider) { Puppet::Provider.new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }
  let(:minimum_supported_version) { '0.9.9.0' }

  before :each do
    allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version)

    resource.provider = provider
  end

  it 'is an instance of Puppet::Type::Chocolateysource' do
    expect(resource).to be_an_instance_of(Puppet::Type::Chocolateysource)
  end

  it 'parameter :name should be the name var' do
    expect(resource.parameters[:name]).to be_isnamevar
  end

  # string values
  ['name', 'location', 'user', 'password'].each do |param|
    context "parameter :#{param}" do
      let(:param_symbol) { param.to_sym }

      it 'accepts any string value' do
        resource[param_symbol] = 'value'
        resource[param_symbol] = 'c:/thisstring-location/value/somefile.txt'
        resource[param_symbol] = 'c:\\thisstring-location\\value\\somefile.txt'
      end
    end
  end

  # boolean values
  ['bypass_proxy', 'admin_only', 'allow_self_service'].each do |param|
    context "parameter :#{param}" do
      let(:param_symbol) { param.to_sym }

      it 'accepts any valid boolean value' do
        resource[param_symbol] = true
        resource[param_symbol] = 'true'
        resource[param_symbol] = false
        resource[param_symbol] = 'false'
      end
    end
  end

  # numeric values
  ['priority'].each do |param|
    context "parameter :#{param}" do
      let(:param_symbol) { param.to_sym }

      it 'accepts any numeric value' do
        resource[param_symbol] = 0
        resource[param_symbol] = 10
      end

      it 'accepts any string that represents a numeric value' do
        resource[param_symbol] = '1'
        resource[param_symbol] = '0'
      end

      it 'does not accept other string values' do
        expect {
          resource[param_symbol] = 'value'
        }.to raise_error(Puppet::Error, %r{An integer is necessary for #{param}})
      end

      it 'does not accept symbol values' do
        expect {
          resource[param_symbol] = :whenever
        }.to raise_error(Puppet::Error, %r{An integer is necessary for #{param}})
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

    it 'accepts :disabled' do
      resource[:ensure] = :disabled
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

  context '.validate' do
    it 'passes when both user/password are empty' do
      resource.validate
    end

    it 'passes when both user/password have a value' do
      resource[:user] = 'tim'
      resource[:password] = 'tim'

      resource.validate
    end

    it 'fails when user has a value but password does not' do
      resource[:user] = 'tim'

      expect {
        resource.validate
      }.to raise_error(ArgumentError, %r{you must specify both values})
    end

    it 'fails when password has a value but user does not' do
      resource[:password] = 'tim'

      expect {
        resource.validate
      }.to raise_error(ArgumentError, %r{you must specify both values})
    end
  end
end
