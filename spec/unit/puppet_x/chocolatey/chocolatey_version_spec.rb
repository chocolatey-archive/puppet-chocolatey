require 'spec_helper'
require 'puppet_x/chocolatey/chocolatey_version'

describe 'Chocolatey Version' do
  context 'on Windows' do
    before :each do
      skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
    end

    context 'when Chocolatey is installed' do
      let(:expected_value) { '1.2.3' }

      before :each do
        allow(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return('c:\dude')
        allow(File).to receive(:exist?).with('c:\dude\choco.exe').and_return(true)
      end

      it 'returns the value from running choco -v' do
        expect(Puppet::Util::Execution).to receive(:execute).and_return(expected_value)

        expect(PuppetX::Chocolatey::ChocolateyVersion.version).to eq expected_value
      end

      it 'handles cleaning up spaces' do
        expect(Puppet::Util::Execution).to receive(:execute).and_return(' ' + expected_value + ' ')

        expect(PuppetX::Chocolatey::ChocolateyVersion.version).to eq expected_value
      end

      it 'handles older versions of choco' do
        expect(Puppet::Util::Execution).to receive(:execute).and_return('Please run chocolatey /? or chocolatey help - chocolatey v' + expected_value)

        expect(PuppetX::Chocolatey::ChocolateyVersion.version).to eq expected_value
      end

      it 'handles other messages that return with version call' do
        expect(Puppet::Util::Execution).to receive(:execute).and_return("Error setting some value.\nPlease set this value yourself\r\nsound good?\r" + expected_value)

        expect(PuppetX::Chocolatey::ChocolateyVersion.version).to eq expected_value
      end

      it 'handles a trailing line break' do
        expect(Puppet::Util::Execution).to receive(:execute).and_return(expected_value + "\r\n")

        expect(PuppetX::Chocolatey::ChocolateyVersion.version).to eq expected_value
      end

      it 'handles 0.9.8.33 of choco' do
        expect(Puppet::Util::Execution).to receive(:execute).and_return('!!ATTENTION!!
The next version of Chocolatey (v0.9.9) will require -y to perform
  behaviors that change state without prompting for confirmation. Start
  using it now in your automated scripts.

  For details on the all new Chocolatey, visit http://bit.ly/new_choco
Please run chocolatey /? or chocolatey help - chocolatey v' + expected_value)

        expect(PuppetX::Chocolatey::ChocolateyVersion.version).to eq expected_value
      end
    end

    context 'When Chocolatey is not installed' do
      it 'returns nil' do
        expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return(nil)
        expect(File).to receive(:exist?).with('\choco.exe').and_return(false)
        expect(PuppetX::Chocolatey::ChocolateyVersion.version).to be_nil
      end
    end
  end

  context 'on Linux' do
    it 'returns nil on a non-windows system' do
      skip 'Not on Linux platform' unless Puppet.features.posix?
      expect(PuppetX::Chocolatey::ChocolateyVersion.version).to be_nil
    end
  end
end
