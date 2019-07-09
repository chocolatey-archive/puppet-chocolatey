require 'spec_helper'
require 'stringio'
require 'puppet/type/package'
require 'puppet/provider/package/chocolatey'
require 'rexml/document'

describe Puppet::Type.type(:package).provider(:chocolatey) do
  let(:resource) { Puppet::Type.type(:package).new(provider: :chocolatey, name: 'chocolatey', package_settings: {}) }
  let(:first_compiled_choco_version) { '0.9.9.0' }
  let(:newer_choco_version) { '0.9.10.0' }
  let(:last_posh_choco_version) { '0.9.8.33' }
  let(:minimum_supported_choco_uninstall_source) { '0.9.10.0' }
  let(:minimum_supported_choco_exit_codes) { '0.9.10.0' }
  let(:minimum_supported_choco_no_progress) { '0.10.4.0' }
  let(:choco_zero_ten_zero) { '0.10.0' }
  let(:choco_zero_eleven_zero) { '0.11.0' }
  let(:choco_config) { 'c:\choco.config' }
  let(:choco_install_path) { 'c:\dude\bin\choco.exe' }
  let(:choco_config_contents) do
    <<-'EOT'
<?xml version="1.0" encoding="utf-8"?>
<chocolatey xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <config>
    <add key="cacheLocation" value="" description="Cache location if not TEMP folder." />
    <add key="commandExecutionTimeoutSeconds" value="2700" description="Default timeout for command execution." />
    <add key="containsLegacyPackageInstalls" value="true" description="Install has packages installed prior to 0.9.9 series." />
    <add key="proxy" value="" description="Explicit proxy location." />
    <add key="proxyUser" value="" description="Optional proxy user." />
    <add key="proxyPassword" value="" description="Optional proxy password. Encrypted." />
    <add key="virusCheckMinimumPositives" value="5" description="Minimum numer of scan result positives before flagging a binary as a possible virus. Available in 0.9.10+. Licensed versions only." />
    <add key="virusScannerType" value="VirusTotal" description="Virus Scanner Type (Generic or VirusTotal). Defaults to VirusTotal for Pro. Available in 0.9.10+. Licensed versions only." />
    <add key="genericVirusScannerPath" value="" description="The full path to the command line virus scanner executable. Used when virusScannerType is Generic. Available in 0.9.10+. Licensed versions only." />
    <add key="genericVirusScannerArgs" value="[[File]]" description="The arguments to pass to the generic virus scanner. Use [[File]] for the file path placeholder. Used when virusScannerType is Generic. Available in 0.9.10+. Licensed versions only." />
    <add key="genericVirusScannerValidExitCodes" value="0" description="The exit codes for the generic virus scanner when a file is not flagged. Separate with comma, defaults to 0. Used when virusScannerType is Generic. Available in 0.9.10+. Licensed versions only." />
  </config>
  <sources>
    <source id="local" value="c:\packages" disabled="true" user="rob" password="bogus/encrypted+value=" priority="0" />
    <source id="chocolatey" value="https://chocolatey.org/api/v2/" disabled="false" priority="0" />
    <source id="chocolatey.licensed" value="https://licensedpackages.chocolatey.org/api/v2/" disabled="false" user="customer" password="bogus/encrypted+value=" priority="10" />
  </sources>
  <features>
    <feature name="checksumFiles" enabled="true" setExplicitly="false" description="Checksum files when pulled in from internet (based on package)." />
    <feature name="virusCheckFiles" enabled="false" setExplicitly="false" />
    <feature name="autoUninstaller" enabled="true" setExplicitly="true" description="Uninstall from programs and features without requiring an explicit uninstall script." />
    <feature name="allowGlobalConfirmation" enabled="false" setExplicitly="true" description="Prompt for confirmation in scripts or bypass." />
    <feature name="allowInsecureConfirmation" enabled="false" setExplicitly="false" />
    <feature name="failOnAutoUninstaller" enabled="false" setExplicitly="false" description="Fail if automatic uninstaller fails." />
    <feature name="failOnStandardError" enabled="false" setExplicitly="false" description="Fail if install provider writes to stderr." />
    <feature name="powershellHost" enabled="true" setExplicitly="false" description="Use Chocolatey''s built-in PowerShell host." />
    <feature name="logEnvironmentValues" enabled="false" setExplicitly="false" description="Log Environment Values - will log values of environment before and after install (could disclose sensitive data)." />
    <feature name="virusCheck" enabled="true" setExplicitly="true" description="Virus Check - perform virus checking on downloaded files. Available in 0.9.10+. Licensed versions only." />
    <feature name="downloadCache" enabled="true" setExplicitly="false" description="Download Cache - use the private download cache if available for a package. Available in 0.9.10+. Licensed versions only." />
    <feature name="failOnInvalidOrMissingLicense" enabled="false" setExplicitly="false" description="Fail On Invalid Or Missing License - allows knowing when a license is expired or not applied to a machine." />
    <feature name="ignoreInvalidOptionsSwitches" enabled="true" setExplicitly="false" description="Ignore Invalid Options/Switches - If a switch or option is passed that is not recognized, should choco fail?" />
    <feature name="usePackageExitCodes" enabled="true" setExplicitly="false" description="Use Package Exit Codes - Package scripts can provide exit codes. With this on, package exit codes will be what choco uses for exit when non-zero (this value can come from a dependency package). Chocolatey defines valid exit codes as 0, 1605, 1614, 1641, 3010. With this feature off, choco will exit with a 0 or a 1 (matching previous behavior). Available in 0.9.10+." />
  </features>
  <apiKeys>
    <apiKeys source="https://chocolatey.org/" key="bogus/encrypted+value=" />
 </apiKeys>
</chocolatey>
  EOT
  end
  let(:choco_config_contents_upec) do
    <<-'EOT'
    <?xml version="1.0" encoding="utf-8"?>
    <chocolatey xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <features>
        <feature name="usePackageExitCodes" enabled="true" setExplicitly="true" description="Use Package Exit Codes - Package scripts can provide exit codes. With this on, package exit codes will be what choco uses for exit when non-zero (this value can come from a dependency package). Chocolatey defines valid exit codes as 0, 1605, 1614, 1641, 3010. With this feature off, choco will exit with a 0 or a 1 (matching previous behavior). Available in 0.9.10+." />
      </features>
    </chocolatey>
  EOT
  end
  let(:provider_class) { subject.class }
  let(:provider) { subject.class.new(resource) }

  before :each do
    resource.provider = provider

    # Stub all file and config tests
    allow(provider_class).to receive(:healthcheck)
    allow(Puppet::Util::Execution).to receive(:execute)
  end

  it 'is an instance of Puppet::Type::Package::ProviderChocolatey' do
    expect(provider).to be_an_instance_of Puppet::Type::Package::ProviderChocolatey
  end

  it 'has an install method' do
    expect(provider).to respond_to(:install)
  end

  it 'has an uninstall method' do
    expect(provider).to respond_to(:uninstall)
  end

  it 'has an update method' do
    expect(provider).to respond_to(:update)
  end

  it 'has a latest method' do
    expect(provider).to respond_to(:latest)
  end

  context 'parameter :source' do
    it 'defaults to nil' do
      expect(resource[:source]).to be_nil
    end

    it 'accepts c:\\packages' do
      resource[:source] = 'c:\packages'
      expect(resource[:source]).to eq('c:\packages')
    end

    it 'accepts http://somelocation/packages' do
      resource[:source] = 'http://somelocation/packages'
      expect(resource[:source]).to eq('http://somelocation/packages')
    end

    it 'accepts \\\\unc\\share\\packages' do
      resource[:source] = '\\unc\share\packages'
      expect(resource[:source]).to eq('\\unc\share\packages')
    end
  end

  context 'self.read_choco_features' do
    it 'errors when the config file location is null' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(nil)

      expect {
        provider.read_choco_features
      }.to raise_error(Puppet::ResourceError, %r{Config file not found for Chocolatey})
    end

    it 'errors when the config file is not found' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(false)

      expect {
        provider.read_choco_features
      }.to raise_error(Puppet::ResourceError, %r{was unable to locate config file at})
    end

    context 'when getting sources from the config file' do
      choco_features = []

      it 'matches the count of sources in the config' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        expect(File).to receive(:read).with(choco_config).and_return choco_config_contents

        choco_features = provider.read_choco_features
        expect(choco_features.count).to eq 14
      end

      it 'contains xml elements' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        expect(File).to receive(:read).with(choco_config).and_return choco_config_contents

        choco_features = provider.read_choco_features
        expect(choco_features[0]).to be_an_instance_of REXML::Element
      end
    end
  end

  context 'self.get_choco_feature' do
    let(:element) { REXML::Element.new('source') }

    element_name           = 'default'
    element_enabled        = 'true'
    element_set_explicitly = 'false'
    element_description    = '10'

    before :each do
      element.add_attributes('name' => element_name,
                             'enabled'       => element_enabled,
                             'setExplicitly' => element_set_explicitly,
                             'description'   => element_description)
    end

    it 'returns nil source when element is nil' do
      expect(provider.get_choco_feature(nil)).to be == {}
    end

    it 'converts an element to a source' do
      choco_feature = provider.get_choco_feature(element)

      expect(choco_feature[:name]).to eq element_name
      expect(choco_feature[:enabled]).to eq element_enabled
      expect(choco_feature[:set_explicitly]).to eq element_set_explicitly
      expect(choco_feature[:description]).to eq element_description
    end
  end

  context 'self.choco_features' do
    it 'returns an array of hashes' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
      expect(File).to receive(:read).with(choco_config).and_return choco_config_contents
      expect(provider.choco_features.count).to eq 14
      provider.choco_features[0].is_a?(Hash)
    end
  end

  context 'when installing' do
    context 'with compiled choco client' do
      before :each do
        allow(provider.class).to receive(:compiled_choco?).and_return(true)
        allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\config\chocolatey.config').and_return(true)
        allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\bin\choco.exe').and_return(true)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        allow(Puppet::Util::Execution).to receive(:execute)
      end

      it 'uses install command without versioned package' do
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil)

        provider.install
      end

      it 'calls with ignore package exit codes when = 0.9.10 and not explicitly configured to use them' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall).twice
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        expect(File).to receive(:read).with(choco_config).and_return choco_config_contents
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_choco_exit_codes).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil, '--ignore-package-exit-codes')

        provider.install
      end

      it 'calls with ignore package exit codes when > 0.9.10 and not explicitly configured to use them' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall).twice
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        expect(File).to receive(:read).with(choco_config).and_return choco_config_contents
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(choco_zero_ten_zero).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil, '--ignore-package-exit-codes')

        provider.install
      end

      it 'does not ignore package exit codes when = 0.9.10 and explicitly configured to use them' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall).twice
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        expect(File).to receive(:read).with(choco_config).and_return choco_config_contents_upec
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(choco_zero_ten_zero).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil)

        provider.install
      end

      it 'calls no progress when = 0.10.4 and not using verbose package options' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall).twice
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        expect(File).to receive(:read).with(choco_config).and_return choco_config_contents
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_choco_no_progress).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil, '--ignore-package-exit-codes', '--no-progress')

        provider.install
      end

      it 'calls no progress when > 0.10.4 and not using verbose package options' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall).twice
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        expect(File).to receive(:read).with(choco_config).and_return choco_config_contents
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(choco_zero_eleven_zero).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil, '--ignore-package-exit-codes', '--no-progress')

        provider.install
      end

      it 'calls no progress when = 0.10.4 and verbose package option specified' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall).twice
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        expect(File).to receive(:read).with(choco_config).and_return choco_config_contents
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_choco_no_progress).at_least(:once)
        resource[:ensure] = :present
        resource[:package_settings] = { 'verbose' => true }
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil, '--ignore-package-exit-codes')

        provider.install
      end

      it 'uses upgrade command with versioned package' do
        resource[:ensure] = '1.2.3'
        expect(provider).to receive(:chocolatey).with('upgrade', 'chocolatey', '--version', '1.2.3', '-y', nil)

        provider.install
      end

      it 'calls install instead of upgrade if package name ends with .config' do
        resource[:name] = 'packages.config'
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('install', 'packages.config', '-y', nil)

        provider.install
      end

      it 'uses source if it is specified' do
        resource[:source] = 'c:\packages'
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', '--source', 'c:\packages', nil)

        provider.install
      end
    end

    context 'with posh choco client' do
      before :each do
        allow(provider.class).to receive(:compiled_choco?).and_return(false)
        allow(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return('c:\dude')
        allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\bin\choco.exe').and_return(true)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(last_posh_choco_version)
      end

      it 'uses install command without versioned package' do
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', nil)

        provider.install
      end

      it 'uses update command with versioned package' do
        resource[:ensure] = '1.2.3'
        expect(provider).to receive(:chocolatey).with('update', 'chocolatey', '--version', '1.2.3', nil)

        provider.install
      end

      it 'uses source if it is specified' do
        resource[:source] = 'c:\packages'
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '--source', 'c:\packages', nil)

        provider.install
      end
    end
  end

  context 'when holding' do
    context 'with compiled choco client' do
      it 'uses install command with held package' do
        allow(provider.class).to receive(:compiled_choco?).and_return(true)
        expect(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return('c:\dude')
        allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with('c:\dude\bin\choco.exe').and_return(true)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        allow(Puppet::Util::Execution).to receive(:execute)

        resource[:ensure] = :held
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil)
        expect(provider).to receive(:chocolatey).with('pin', 'add', '-n', 'chocolatey')

        provider.hold
      end
    end

    context 'with posh choco client' do
      before :each do
        allow(provider.class).to receive(:compiled_choco?).and_return(false)
      end

      it 'throws an argument error with held package' do
        resource[:ensure] = :held

        expect { provider.hold }.to raise_error(ArgumentError, 'Only choco v0.9.9+ can use ensure => held')
      end
    end
  end

  context 'when uninstalling' do
    context 'with compiled choco client' do
      before :each do
        allow(provider).to receive(:use_package_exit_codes_feature_enabled?).and_return(false)
        allow(provider.class).to receive(:compiled_choco?).and_return(true)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        allow(Puppet::Util::Execution).to receive(:execute)
      end

      it 'calls the remove operation' do
        expect(provider).to receive(:chocolatey).with('uninstall', 'chocolatey', '-fy', nil)

        provider.uninstall
      end

      it 'calls with ignore package exit codes when = 0.9.10' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_choco_exit_codes).at_least(:once)
        expect(provider).to receive(:chocolatey).with('uninstall', 'chocolatey', '-fy', nil, '--ignore-package-exit-codes')

        provider.uninstall
      end

      it 'calls with ignore package exit codes when > 0.9.10' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(choco_zero_ten_zero).at_least(:once)
        expect(provider).to receive(:chocolatey).with('uninstall', 'chocolatey', '-fy', nil, '--ignore-package-exit-codes')

        provider.uninstall
      end

      it 'uses ignore source if it is specified and the version is less than 0.9.10' do
        resource[:source] = 'c:\packages'
        expect(provider).to receive(:chocolatey).with('uninstall', 'chocolatey', '-fy', nil)

        provider.uninstall
      end

      it 'uses source if it is specified and the version is at least 0.9.10' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_choco_uninstall_source).at_least(:once)
        resource[:source] = 'c:\packages'
        expect(provider).to receive(:chocolatey).with('uninstall', 'chocolatey', '-fy', '--source', 'c:\packages', nil, '--ignore-package-exit-codes')

        provider.uninstall
      end

      it 'uses source if it is specified and the version is greater than 0.9.10' do
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(choco_zero_ten_zero).at_least(:once)
        resource[:source] = 'c:\packages'
        expect(provider).to receive(:chocolatey).with('uninstall', 'chocolatey', '-fy', '--source', 'c:\packages', nil, '--ignore-package-exit-codes')

        provider.uninstall
      end
    end

    context 'with posh choco client' do
      before :each do
        allow(provider.class).to receive(:compiled_choco?).and_return(false)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(last_posh_choco_version)
      end

      it 'calls the remove operation' do
        expect(provider).to receive(:chocolatey).with('uninstall', 'chocolatey', nil)

        provider.uninstall
      end

      it 'uses source if it is specified' do
        resource[:source] = 'c:\packages'
        expect(provider).to receive(:chocolatey).with('uninstall', 'chocolatey', '--source', 'c:\packages', nil)

        provider.uninstall
      end
    end
  end

  context 'when updating' do
    context 'with compiled choco client' do
      before :each do
        allow(provider).to receive(:use_package_exit_codes_feature_enabled?).and_return(false)
        allow(provider.class).to receive(:compiled_choco?).and_return(true)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        allow(Puppet::Util::Execution).to receive(:execute)
      end

      it 'uses `chocolatey upgrade` when ensure latest and package present' do
        allow(provider_class).to receive(:instances).and_return [provider_class.new(ensure: '1.2.3',
                                                                                    name: 'chocolatey',
                                                                                    provider: :chocolatey)]
        expect(provider).to receive(:chocolatey).with('upgrade', 'chocolatey', '-y', nil)

        provider.update
      end

      it 'calls with ignore package exit codes when = 0.9.10' do
        allow(provider_class).to receive(:instances).and_return [provider_class.new(ensure: '1.2.3',
                                                                                    name: 'chocolatey',
                                                                                    provider: :chocolatey)]
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_choco_exit_codes).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('upgrade', 'chocolatey', '-y', nil, '--ignore-package-exit-codes')

        provider.update
      end

      it 'calls with ignore package exit codes when > 0.9.10' do
        allow(provider_class).to receive(:instances).and_return [provider_class.new(ensure: '1.2.3',
                                                                                    name: 'chocolatey',
                                                                                    provider: :chocolatey)]
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(choco_zero_ten_zero).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('upgrade', 'chocolatey', '-y', nil, '--ignore-package-exit-codes')

        provider.update
      end

      it 'calls with no-progress when = 0.10.4 and package_settings: verbose is not true' do
        allow(provider_class).to receive(:instances).and_return [provider_class.new(ensure: '1.2.3',
                                                                                    name: 'chocolatey',
                                                                                    provider: :chocolatey)]
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_choco_no_progress).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('upgrade', 'chocolatey', '-y', nil, '--ignore-package-exit-codes', '--no-progress')

        provider.update
      end

      it 'calls with no-progress when > 0.10.4 and package_settings: verbose is not true' do
        allow(provider_class).to receive(:instances).and_return [provider_class.new(ensure: '1.2.3',
                                                                                    name: 'chocolatey',
                                                                                    provider: :chocolatey)]
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(choco_zero_eleven_zero).at_least(:once)
        resource[:ensure] = :present
        expect(provider).to receive(:chocolatey).with('upgrade', 'chocolatey', '-y', nil, '--ignore-package-exit-codes', '--no-progress')

        provider.update
      end

      it 'does not call with no-progress when = 0.10.4 and package_settings: verbose is true' do
        allow(provider_class).to receive(:instances).and_return [provider_class.new(ensure: '1.2.3',
                                                                                    name: 'chocolatey',
                                                                                    provider: :chocolatey)]
        expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_choco_no_progress).at_least(:once)
        resource[:package_settings] = { 'verbose' => true }
        resource[:ensure]           = :present
        expect(provider).to receive(:chocolatey).with('upgrade', 'chocolatey', '-y', nil, '--ignore-package-exit-codes')

        provider.update
      end

      it 'uses `chocolatey install` when ensure latest and package absent' do
        allow(provider_class).to receive(:instances).and_return []
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', '-y', nil)

        provider.update
      end

      it 'uses source if it is specified' do
        expect(provider_class).to receive(:instances).and_return [provider_class.new(ensure: 'latest',
                                                                                     name: 'chocolatey',
                                                                                     provider: :chocolatey)]
        resource[:source] = 'c:\packages'
        expect(provider).to receive(:chocolatey).with('upgrade', 'chocolatey', '-y', '--source', 'c:\packages', nil)

        provider.update
      end
    end

    context 'with posh choco client' do
      before :each do
        allow(provider.class).to receive(:compiled_choco?).and_return(false)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(last_posh_choco_version)
      end

      it 'uses `chocolatey update` when ensure latest and package present' do
        allow(provider_class).to receive(:instances).and_return [provider_class.new(ensure: '1.2.3',
                                                                                    name: 'chocolatey',
                                                                                    provider: :chocolatey)]
        expect(provider).to receive(:chocolatey).with('update', 'chocolatey', nil)

        provider.update
      end

      it 'uses `chocolatey install` when ensure latest and package absent' do
        allow(provider_class).to receive(:instances).and_return []
        expect(provider).to receive(:chocolatey).with('install', 'chocolatey', nil)

        provider.update
      end

      it 'uses source if it is specified' do
        expect(provider_class).to receive(:instances).and_return [provider_class.new(ensure: 'latest',
                                                                                     name: 'chocolatey',
                                                                                     provider: :chocolatey)]
        resource[:source] = 'c:\packages'
        expect(provider).to receive(:chocolatey).with('update', 'chocolatey', '--source', 'c:\packages', nil)

        provider.update
      end
    end
  end

  context 'when getting latest' do
    context 'with compiled choco client' do
      before :each do
        allow(provider.class).to receive(:compiled_choco?).and_return(true)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(first_compiled_choco_version)
      end

      it 'uses choco.exe arguments' do
        # we don't care where choco is, we are concerned with the arguments that are passed to choco.
        #
        expect(provider.send(:latestcmd).drop(1)).to eq ['upgrade', '--noop', 'chocolatey', '-r']
      end

      it 'uses source if it is specified' do
        resource[:source] = 'c:\packages'
        expect(provider.send(:latestcmd).drop(1)).to eq ['upgrade', '--noop', 'chocolatey', '-r', '--source', 'c:\packages']
        # expect(provider).to receive(:chocolatey).with('upgrade', '--noop', 'chocolatey','-r', '--source', 'c:\packages')

        # provider.latest
      end
    end

    context 'with posh choco client' do
      before :each do
        allow(provider.class).to receive(:compiled_choco?).and_return(false)
        allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(last_posh_choco_version)
      end

      it 'uses posh arguments' do
        expect(provider.send(:latestcmd).drop(1)).to eq ['version', 'chocolatey', '| findstr /R "latest" | findstr /V "latestCompare"']
      end

      it 'uses source if it is specified' do
        resource[:source] = 'c:\packages'
        expect(provider.send(:latestcmd).drop(1)).to eq ['version', 'chocolatey', '--source', 'c:\packages', '| findstr /R "latest" | findstr /V "latestCompare"']
        # expect(provider).to receive(:chocolatey).with('version', 'chocolatey', '--source', 'c:\packages', '| findstr /R "latest" | findstr /V "latestCompare"')

        # provider.latest
      end
    end
  end

  context 'query' do
    it 'returns a hash when chocolatey and the package are present' do
      expect(provider_class).to receive(:instances).and_return [provider_class.new(ensure: '1.2.5',
                                                                                   name: 'chocolatey',
                                                                                   provider: :chocolatey)]

      expect(provider.query).to eq(ensure: '1.2.5',
                                   name: 'chocolatey',
                                   provider: :chocolatey)
    end

    it 'returns nil when the package is missing' do
      expect(provider_class).to receive(:instances).and_return []

      expect(provider.query).to be_nil
    end
  end

  context 'when fetching a package list' do
    it 'invokes provider listcmd' do
      expect(provider_class).to receive(:listcmd)

      provider_class.instances
    end

    it 'queries chocolatey' do
      expect(provider_class).to receive(:execpipe) do |args|
        expect(args[1]).to match(%r{list})
        expect(args[2]).to match(%r{-lo})
      end

      provider_class.instances
    end

    context 'self.instances' do
      it 'returns nil on error' do
        expect(provider_class).to receive(:execpipe).and_raise(Puppet::ExecutionFailure.new('ERROR!'))

        expect(provider_class.instances).to be_nil
      end

      context 'with compiled choco client' do
        before :each do
          allow(provider.class).to receive(:compiled_choco?).and_return(true)
          allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(first_compiled_choco_version)
        end

        it 'returns installed packages with their versions' do
          expect(provider_class).to receive(:execpipe).and_yield(StringIO.new(%(package1|1.23\n\package2|2.00\n)))

          packages = provider_class.instances

          expect(packages.length).to eq(2)

          expect(packages[0].properties).to eq(provider: :chocolatey,
                                               ensure: '1.23',
                                               name: 'package1')

          expect(packages[1].properties).to eq(provider: :chocolatey,
                                               ensure: '2.00',
                                               name: 'package2')
        end

        it 'returns nil on error' do
          expect(provider_class).to receive(:execpipe).and_yield(StringIO.new(%(Unable to search for packages when there are no soures enabled for packages and none were passed as arguments.\n)))

          expect {
            provider_class.instances
          }.to raise_error(Puppet::Error, %r{At least one source must be enabled.})
        end
      end

      context 'with posh choco client' do
        before :each do
          allow(provider.class).to receive(:compiled_choco?).and_return(false)
          allow(PuppetX::Chocolatey::ChocolateyVersion).to receive(:version).and_return(last_posh_choco_version)
        end

        it 'returns installed packages with their versions' do
          expect(provider_class).to receive(:execpipe).and_yield(StringIO.new(%(package1 1.23\n\package2 2.00\n)))

          packages = provider_class.instances

          expect(packages.length).to eq(2)

          expect(packages[0].properties).to eq(provider: :chocolatey,
                                               ensure: '1.23',
                                               name: 'package1')

          expect(packages[1].properties).to eq(provider: :chocolatey,
                                               ensure: '2.00',
                                               name: 'package2')
        end
      end
    end
  end
end
