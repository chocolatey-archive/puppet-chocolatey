require 'spec_helper'
require 'stringio'
require 'puppet/type/chocolateysource'
require 'puppet/provider/chocolateysource/windows'
require 'rexml/document'

provider = Puppet::Type.type(:chocolateysource).provider(:windows)
describe provider do
  let(:name) { 'sourcename' }
  let(:location) { 'c:\packages' }
  let(:resource) { Puppet::Type.type(:chocolateysource).new(provider: :windows, name: name, location: location) }
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

  let(:newer_choco_version) { '0.10.9' }
  let(:minimum_supported_version_priority) { '0.9.9.9' }
  let(:last_unsupported_version_priority) { '0.9.9.8' }
  let(:minimum_supported_version_bypass_proxy) { '0.10.4' }
  let(:last_unsupported_version_bypass_proxy) { '0.10.3' }
  let(:minimum_supported_version_allow_self_service) { '0.10.4' }
  let(:last_unsupported_version_allow_self_service) { '0.10.3' }
  let(:minimum_supported_version_admin_only) { '0.10.8' }
  let(:last_unsupported_version_admin_only) { '0.10.7' }
  let(:minimum_supported_version) { '0.9.9.0' }
  let(:last_unsupported_version) { '0.9.8.33' }
  let(:provider_class) { subject.class }
  let(:provider) { subject.class.new(resource) }

  before :each do
    allow(PuppetX::Chocolatey::ChocolateyInstall).to receive(:install_path).and_return('c:\dude')
    allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version)

    provider = provider_class.new(resource)
    resource.provider = provider

    # Stub all file and config tests
    allow(provider_class).to receive(:healthcheck)
  end

  context 'verify provider' do
    it 'is an instance of Puppet::Type::Chocolateysource::ProviderWindows' do
      expect(provider).to be_an_instance_of(Puppet::Type::Chocolateysource::ProviderWindows)
    end

    it 'has a create method' do
      expect(provider).to respond_to(:create)
    end

    it 'has an exists? method' do
      expect(provider).to respond_to(:exists?)
    end

    it 'has a disable method' do
      expect(provider).to respond_to(:disable)
    end

    it 'has a destroy method' do
      expect(provider).to respond_to(:destroy)
    end

    it 'has a properties method' do
      expect(provider).to respond_to(:properties)
    end

    it 'has a query method' do
      expect(provider).to respond_to(:query)
    end
  end

  context 'properties' do
    context ':location' do
      it 'accepts c:\\packages' do
        resource[:location] = 'c:\packages'
      end

      it 'accepts http://somelocation/packages' do
        resource[:location] = 'http://somelocation/packages'
      end

      it 'accepts \\\\unc\\share\\packages' do
        resource[:location] = '\\unc\share\packages'
      end
    end

    context ':user' do
      it "accepts 'bob'" do
        resource[:user] = 'bob'
      end

      it "accepts 'domain\\bob'" do
        resource[:user] = 'domain\bob'
      end

      it "accepts api keys like 'api123-456-243 d123'" do
        resource[:user] = 'api123-456-243 d123'
      end
    end

    context ':password' do
      it "accepts 'bob'" do
        resource[:password] = 'bob'
      end

      it "accepts api keys like 'api123-456-243 d123'" do
        resource[:password] = 'api123-456-243 d123'
      end
    end

    context ':bypass_proxy' do
      it "accepts 'true' as a string" do
        resource[:bypass_proxy] = 'true'
      end
      it "accepts 'true as a boolean'" do
        resource[:bypass_proxy] = true
      end
    end

    context ':allow_self_service' do
      it "accepts 'true' as a string" do
        resource[:allow_self_service] = 'true'
      end
      it "accepts 'true as a boolean'" do
        resource[:allow_self_service] = true
      end
    end

    context ':admin_only' do
      it "accepts 'true' as a string" do
        resource[:admin_only] = 'true'
      end
      it "accepts 'true as a boolean'" do
        resource[:admin_only] = true
      end
    end
  end

  context 'self.read_sources' do
    it 'errors when the config file location is null' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(nil)

      expect {
        provider_class.read_sources
      }.to raise_error(Puppet::ResourceError, %r{Config file not found for Chocolatey})
    end

    it 'errors when the config file is not found' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(false)

      expect {
        provider_class.read_sources
      }.to raise_error(Puppet::ResourceError, %r{was unable to locate config file at})
    end

    context 'when getting sources from the config file' do
      sources = []

      before :each do
        allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config)
        allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true)
        allow(File).to receive(:read).with(choco_config).and_return choco_config_contents

        sources = provider_class.read_sources
      end

      it 'matches the count of sources in the config' do
        expect(sources.count).to eq(3)
      end

      it 'contains xml elements' do
        expect(sources[0]).to be_an_instance_of(REXML::Element)
      end
    end
  end

  context 'self.get_source' do
    let(:element) { REXML::Element.new('source') }

    element_id = 'default'
    element_value = 'c:\\packages'
    element_disabled = 'false'
    element_priority = '10'
    element_user = 'thisguy'
    element_password = 'super/encrypted+value=='
    element_bypass_proxy = 'true'
    element_allow_self_service = 'true'
    element_admin_only = 'true'

    before :each do
      element.add_attributes('id' => element_id,
                             'value'       => element_value,
                             'disabled'    => element_disabled,
                             'priority'    => element_priority,
                             'user'        => element_user,
                             'password'    => element_password,
                             'bypassProxy' => element_bypass_proxy,
                             'selfService' => element_allow_self_service,
                             'adminOnly'   => element_admin_only)
    end

    it 'returns nil source when element it nil' do
      expect(provider_class.get_source(nil)).to be == {}
    end

    it 'converts an element to a source' do
      source = provider_class.get_source(element)

      expect(source[:name]).to eq element_id
      expect(source[:location]).to eq element_value
      expect(source[:priority]).to eq element_priority
      expect(source[:user]).to eq element_user
      expect(source[:ensure]).to eq :present
      expect(source[:bypass_proxy]).to eq element_bypass_proxy
      expect(source[:allow_self_service]).to eq element_allow_self_service
      expect(source[:admin_only]).to eq element_admin_only
    end

    it 'converts a bare bones element to a source' do
      element.delete_attribute('disabled')
      element.delete_attribute('priority')
      element.delete_attribute('user')
      element.delete_attribute('password')
      element.delete_attribute('bypassProxy')
      element.delete_attribute('selfService')
      element.delete_attribute('adminOnly')

      source = provider_class.get_source(element)

      expect(source[:name]).to eq element_id
      expect(source[:location]).to eq element_value
      expect(source[:ensure]).to eq :present
    end

    it 'when source is disabled' do
      element.delete_attribute('disabled')
      element.add_attribute('disabled', 'true')

      source = provider_class.get_source(element)
      expect(source[:ensure]).to eq :disabled
    end
  end

  context '.validation' do
    before :each do
      allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).and_return(true)
      allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_install_path).and_return(true)
    end

    it 'does not warn when both user/password are empty' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version)
      expect(Puppet).to receive(:warning).never
      expect(Puppet).to receive(:debug).never

      resource.provider.validate
    end

    it 'throws when choco version is less than the minimum supported version' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version)

      expect {
        resource.provider.validate
      }.to raise_error(Puppet::Error, %r{Chocolatey version must be '0.9.9.0' to manage configuration values with Puppet})
    end

    it 'writes a debug message on password when password is not empty' do
      resource[:user] = 'tim'
      resource[:password] = 'tim'

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet).to receive(:warning).never
      expect(Puppet).to receive(:debug).with('The password is not ensurable, so Puppet is unable to change the value using chocolateysource resource. '\
        "As a workaround, a password change can be in the form of an exec. Reference Chocolateysource[#{name}]")

      resource.provider.validate
    end

    it 'does not warn on user/password on newer choco versions' do
      resource[:user] = 'tim'
      resource[:password] = 'tim'

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn on user/password when choco version is the minimum supported version' do
      resource[:user] = 'tim'
      resource[:password] = 'tim'

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn on bypass_proxy when choco version is newer than the minimum supported version' do
      resource[:bypass_proxy] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn on bypass_proxy when choco version is the minimum supported version' do
      resource[:bypass_proxy] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version_bypass_proxy)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'warns on bypass_proxy when choco version is less than the minimum supported version' do
      resource[:bypass_proxy] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_bypass_proxy)
      expect(Puppet).to receive(:warning).with('Chocolatey is unable to specify bypassing system proxy for sources when version is less than 0.10.4. The value you set will be ignored.')

      resource.provider.validate
    end

    it 'does not warn on allow_self_service when choco version is newer than the minimum supported version' do
      resource[:allow_self_service] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn on allow_self_service when choco version is the minimum supported version' do
      resource[:allow_self_service] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version_allow_self_service)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'warns on allow_self_service when choco version is less than the minimum supported version' do
      resource[:allow_self_service] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_allow_self_service)
      expect(Puppet).to receive(:warning).with('Chocolatey is unable to specify self-service for sources when version is less than 0.10.4. The value you set will be ignored.')

      resource.provider.validate
    end

    it 'does not warn on admin_only when choco version is newer than the minimum supported version' do
      resource[:admin_only] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn on admin_only when choco version is the minimum supported version' do
      resource[:admin_only] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version_admin_only)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'warns on admin_only when choco version is less than the minimum supported version' do
      resource[:admin_only] = true

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_admin_only)
      expect(Puppet).to receive(:warning).with('Chocolatey is unable to specify administrator only visibility for sources when version is less than 0.10.8. The value you set will be ignored.')

      resource.provider.validate
    end

    it 'does not warn if priority is not set' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn if priority is not set on older unsupported versions' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_priority)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn if priority is 0 on unsupported versions' do
      resource[:priority] = 0

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_priority)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn on priority when choco version is newer than the minimum supported version' do
      resource[:priority] = 10

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'does not warn on priority when choco version is the minimum supported version' do
      resource[:priority] = 10

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version_priority)
      expect(Puppet).to receive(:warning).never

      resource.provider.validate
    end

    it 'warns on priority when choco version is less than the minimum supported version' do
      resource[:priority] = 10

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_priority)
      expect(Puppet).to receive(:warning).with('Chocolatey is unable to manage priority for sources when version is less than 0.9.9.9. The value you set will be ignored.')

      resource.provider.validate
    end

    it 'passes when ensure is not present and location is empty' do
      no_location_resource = Puppet::Type.type(:chocolateysource).new(name: 'source', ensure: :disabled)
      no_location_resource.provider = provider_class.new(no_location_resource)

      no_location_resource.provider.validate
    end

    it 'fails when ensure => present and location is empty' do
      expect {
        no_location_resource = Puppet::Type.type(:chocolateysource).new(name: 'source')
        no_location_resource.provider = provider_class.new(no_location_resource)

        no_location_resource.provider.validate
      }.to raise_error(Exception, %r{non-empty location})
      # check for just an exception here
      # In some versions of Puppet, this comes back as ArgumentError
      # In other versions of Puppet, this comes back as Puppet::Error
    end
  end

  context '.flush' do
    resource_name = 'yup'
    resource_location = 'loc'
    resource_ensure = :present
    resource_priority = '10'
    resource_user = 'thatguy'
    resource_password = 'secrets!'
    resource_bypass_proxy = :true
    resource_allow_self_service = :true
    resource_admin_only = :true

    before :each do
      allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:set_env_chocolateyinstall).at_most(:once)
      allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_config_file).and_return(choco_config).at_most(:once)
      allow(PuppetX::Chocolatey::ChocolateyCommon).to receive(:file_exists?).with(choco_config).and_return(true).at_most(:once)
      allow(File).to receive(:read).with(choco_config).and_return(choco_config_contents).at_most(:once)

      resource[:name] = resource_name
      resource[:location] = resource_location
      resource[:ensure] = resource_ensure
    end

    it 'ensures a source is present with minimal values set' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--priority', '0'], {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', 'yup'])

      resource.flush
    end

    it 'ensures a source is present with all values set' do
      resource[:priority] = resource_priority
      resource[:user] = resource_user
      resource[:password] = resource_password
      resource[:bypass_proxy] = resource_bypass_proxy
      resource[:allow_self_service] = resource_allow_self_service
      resource[:admin_only] = resource_admin_only

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--user', resource_user,
                                                                 '--password', resource_password,
                                                                 '--bypass-proxy',
                                                                 '--allow-self-service',
                                                                 '--admin-only',
                                                                 '--priority', resource_priority], combine: true, failonfail: true, sensitive: true)

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets priority when present' do
      resource[:priority] = resource_priority
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--priority', resource_priority], {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets bypass_proxy when present' do
      resource[:bypass_proxy] = resource_bypass_proxy

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--bypass-proxy',
                                                                 '--priority', '0'],
                                                                {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets allow_self_service when present' do
      resource[:allow_self_service] = resource_allow_self_service

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--allow-self-service',
                                                                 '--priority', '0'],
                                                                {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets admin_only when present' do
      resource[:admin_only] = resource_admin_only

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--admin-only',
                                                                 '--priority', '0'],
                                                                {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets user and password when user is present' do
      resource[:user] = resource_user
      resource[:password] = resource_password

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--user', resource_user,
                                                                 '--password', resource_password,
                                                                 '--priority', '0'], combine: true, failonfail: true, sensitive: true)

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets user and password when choco version is the minimum supported version' do
      resource[:user] = resource_user
      resource[:password] = resource_password

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--user', resource_user,
                                                                 '--password', resource_password], combine: true, failonfail: true, sensitive: true)

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'does not set bypass_proxy when choco version is less than the minimum supported version' do
      resource[:bypass_proxy] = resource_bypass_proxy

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_bypass_proxy)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--priority', '0'], {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets bypass_proxy when choco version is the minimum supported version' do
      resource[:bypass_proxy] = resource_bypass_proxy

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version_bypass_proxy)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--bypass-proxy',
                                                                 '--priority', '0'], {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'does not set allow_self_service when choco version is less than the minimum supported version' do
      resource[:allow_self_service] = resource_allow_self_service

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_allow_self_service)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--priority', '0'], {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets allow_self_service when choco version is the minimum supported version' do
      resource[:allow_self_service] = resource_allow_self_service

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version_allow_self_service)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--allow-self-service',
                                                                 '--priority', '0'], {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets admin_only when choco version is the minimum supported version' do
      resource[:admin_only] = resource_admin_only

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version_admin_only)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--admin-only',
                                                                 '--priority', '0'], {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets priority when choco version is newer than the minimum supported version' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--priority', '0'],
                                                                {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'sets priority when choco version is the minimum supported version' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(minimum_supported_version_priority)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--priority', '0'],
                                                                {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'does not set priority when choco version is less than the minimum supported version' do
      resource[:priority] = resource_priority

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(last_unsupported_version_priority)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location],
                                                                {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', resource_name])

      resource.flush
    end

    it 'disables a source when ensure => disabled' do
      resource[:ensure] = :disabled
      resource[:name] = 'chocolatey'
      resource.provider.disable

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'disable',
                                                                 '--name', 'chocolatey'],
                                                                {})

      resource.flush
    end

    it 'removes a source when ensure => absent' do
      resource[:ensure] = :absent
      resource.provider.destroy

      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).never
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'remove',
                                                                 '--name', resource_name],
                                                                {})

      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'enable',
                                                                 '--name', 'yup']).never

      resource.flush
    end

    it 'provides an error message when choco execution fails' do
      expect(PuppetX::Chocolatey::ChocolateyCommon).to receive(:choco_version).and_return(newer_choco_version)
      expect(Puppet::Util::Execution).to receive(:execute).with([provider_class.command(:chocolatey),
                                                                 'source', 'add',
                                                                 '--name', resource_name,
                                                                 '--source', resource_location,
                                                                 '--priority', '0'], {}).and_raise(Puppet::ExecutionFailure, 'Nooooo')

      expect { resource.flush }.to raise_error(Puppet::Error, %r{Unable to set Chocolatey source})
    end
  end
end
