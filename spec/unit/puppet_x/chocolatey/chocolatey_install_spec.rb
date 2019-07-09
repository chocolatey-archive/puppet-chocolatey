# rubocop:disable RSpec/AnyInstance

require 'spec_helper'
require 'puppet_x/chocolatey/chocolatey_install'

describe 'Chocolatey Install Location' do
  context 'using normal install path' do
    context 'on Windows' do
      before :each do
        skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
      end

      it 'returns install path from registry if it exists' do
        expected_value = 'C:\somewhere'
        allow_any_instance_of(Win32::Registry).to receive(:[]).with('ChocolateyInstall').and_return(expected_value)

        expect(PuppetX::Chocolatey::ChocolateyInstall.install_path).to eq expected_value
      end

      it 'returns the environment variable ChocolateyInstall if it exists' do
        allow_any_instance_of(Win32::Registry).to receive(:[]).with('ChocolateyInstall').and_raise(Win32::Registry::Error.new(2), 'file not found yo')

        # this is a placeholder, it is already set in spec_helper
        ENV['ChocolateyInstall'] = 'c:\blah'

        expect(PuppetX::Chocolatey::ChocolateyInstall.install_path).to eq 'c:\blah'
      end

      it 'returns nil if the environment variable does not exist' do
        allow_any_instance_of(Win32::Registry).to receive(:[]).with('ChocolateyInstall').and_raise(Win32::Registry::Error.new(2), 'file not found yo')
        ENV['ChocolateyInstall'] = nil

        expect(PuppetX::Chocolatey::ChocolateyInstall.install_path).to be_nil
      end
    end

    context 'on Linux' do
      before :each do
        skip 'Not on Linux platform' unless Puppet.features.posix?
      end

      it 'returns the environment variable ChocolateyInstall if it exists' do
        # this is a placeholder, it is already set in spec_helper
        ENV['ChocolateyInstall'] = 'c:\blah'

        expect(PuppetX::Chocolatey::ChocolateyInstall.install_path).to eq 'c:\blah'
      end

      it 'returns nil if the ChocolateyInstall variable does not exist' do
        ENV['ChocolateyInstall'] = nil

        expect(PuppetX::Chocolatey::ChocolateyInstall.install_path).to be_nil
      end
    end

    after :each do
      # setting the values back
      ENV['ChocolateyInstall'] = 'c:\blah'
    end
  end

  context 'using temp directory' do
    before :each do
      skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
    end

    it 'returns the TEMP path from registry if it exists' do
      expected_value = 'C:\somewhere'
      allow_any_instance_of(Win32::Registry).to receive(:[]).with('TEMP').and_return(expected_value)

      expect(PuppetX::Chocolatey::ChocolateyInstall.temp_dir).to eq expected_value
    end
    it 'returns nil path from registry if it does not exist' do
      allow_any_instance_of(Win32::Registry).to receive(:[]).with('TEMP').and_raise(Win32::Registry::Error.new(2), 'file not found yo')

      expect(PuppetX::Chocolatey::ChocolateyInstall.temp_dir).to be_nil
    end
  end
end

# rubocop:enable RSpec/AnyInstance
