require 'spec_helper'
require 'puppet_x/chocolatey/chocolatey_install'
require 'puppet_x/chocolatey/chocolatey_common'

describe 'Chocolatey Common' do
  let(:first_compiled_choco_version) { '0.9.9.0' }
  let(:newer_choco_version) { '0.9.10.0' }
  let(:last_posh_choco_version) { '0.9.8.33' }

  before :each do
    allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall)
  end

  context '.chocolatey_command' do
    before :each do
      skip 'Not on Windows platform' unless Puppet.features.microsoft_windows?
    end

    it 'finds chocolatey install location based on PuppetX::Chocolatey::ChocolateyInstall' do
      expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return('c:\dude')
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\choco.exe').and_return(true)

      PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command.should == 'c:\dude\choco.exe'
    end

    it 'finds chocolatey install location based on default location' do
      expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return('c:\dude')
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\choco.exe').and_return(false)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('C:\ProgramData\chocolatey\choco.exe').and_return(false)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('C:\Chocolatey\choco.exe').and_return(false)

      PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command.should == "#{ENV['ALLUSERSPROFILE']}\\chocolatey\\choco.exe"
    end
  end

  context '.choco_version' do
    it 'returns PuppetX::Chocolatey::ChocolateyVersion.version' do
      expected = '0.9.9.0.1'
      expect(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(expected)
      PuppetX::Chocolatey::ChocolateyCommon.clear_cached_values

      expect(PuppetX::Chocolatey::ChocolateyCommon.choco_version).to eq expected
    end
  end

  context '.choco_config_file' do
    let(:choco_install_loc) { 'c:\dude' }

    it 'returns the normal config file location when found' do
      expected = 'c:\dude\config\chocolatey.config'
      expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return(choco_install_loc)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(expected).and_return(true)

      expect(PuppetX::Chocolatey::ChocolateyCommon.choco_config_file).to eq expected
    end

    it 'returns the old config file location for older installs' do
      expected = 'c:\dude\chocolateyinstall\chocolatey.config'
      expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return(choco_install_loc)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\config\chocolatey.config').and_return(false)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(expected).and_return(true)

      expect(PuppetX::Chocolatey::ChocolateyCommon.choco_config_file).to eq expected
    end

    it 'returns nil when the config cannot be found' do
      expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return(choco_install_loc)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\config\chocolatey.config').and_return(false)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\chocolateyinstall\chocolatey.config').and_return(false)

      expect(PuppetX::Chocolatey::ChocolateyCommon.choco_config_file).to be_nil
    end
  end
end
