require 'spec_helper'
require 'stringio'
require 'puppet/type/package'
require 'puppet/provider/package/chocolatey'
require 'rexml/document'

provider = Puppet::Type.type(:package).provider(:chocolatey)

describe provider do
  let (:resource) { Puppet::Type.type(:package).new(:provider => :chocolatey, :name => "chocolatey") }
  let (:first_compiled_choco_version) {'0.9.9.0'}
  let (:newer_choco_version) {'0.9.10.0'}
  let (:last_posh_choco_version) {'0.9.8.33'}
  let (:minimum_supported_choco_uninstall_source) {'0.9.10.0'}
  let (:minimum_supported_choco_exit_codes) {'0.9.10.0'}
  let (:choco_zero_ten_zero) {'0.10.0'}
  let (:choco_config) { 'c:\choco.config' }
  let (:choco_install_path) { 'c:\dude\bin\choco.exe' }
  let (:choco_config_contents) { <<-'EOT'
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
  }
  let (:choco_config_contents_upec) { <<-'EOT'
    <?xml version="1.0" encoding="utf-8"?>
    <chocolatey xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <features>
        <feature name="usePackageExitCodes" enabled="true" setExplicitly="true" description="Use Package Exit Codes - Package scripts can provide exit codes. With this on, package exit codes will be what choco uses for exit when non-zero (this value can come from a dependency package). Chocolatey defines valid exit codes as 0, 1605, 1614, 1641, 3010. With this feature off, choco will exit with a 0 or a 1 (matching previous behavior). Available in 0.9.10+." />
      </features>
    </chocolatey>
  EOT
  }

  before :each do
    @provider = provider.new(resource)
    resource.provider = @provider

    # Stub all file and config tests
    provider.stubs(:healthcheck)
    Puppet::Util::Execution.stubs(:execute)
  end

  it "should be an instance of Puppet::Type::Package::ProviderChocolatey" do
    @provider.must be_an_instance_of Puppet::Type::Package::ProviderChocolatey
  end

  it "should have an install method" do
    @provider.should respond_to(:install)
  end

  it "should have a latest method" do
    @provider.should respond_to(:uninstall)
  end

  it "should have an update method" do
    @provider.should respond_to(:update)
  end

  it "should have a latest method" do
    @provider.should respond_to(:latest)
  end

  context "parameter :source" do
    it "should default to nil" do
      resource[:source].should be_nil
    end

    it "should accept c:\\packages" do
      resource[:source] = 'c:\packages'
    end

    it "should accept http://somelocation/packages" do
      resource[:source] = 'http://somelocation/packages'
    end

    it "should accept \\\\unc\\share\\packages" do
      resource[:source] = '\\unc\share\packages'
    end
  end

  context "self.get_choco_features" do
    before :each do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall)
    end

    it "should error when the config file location is null" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(nil)

      expect {
        @provider.get_choco_features
      }.to raise_error(Puppet::ResourceError, /Config file not found for Chocolatey/)
    end

    it "should error when the config file is not found" do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(false)

      expect {
        @provider.get_choco_features
      }.to raise_error(Puppet::ResourceError, /was unable to locate config file at/)
    end

    context "when getting sources from the config file" do
      choco_features = []

      before :each do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(true)
        File.expects(:read).with(choco_config).returns choco_config_contents

        choco_features = @provider.get_choco_features
      end

      it "should match the count of sources in the config" do
        choco_features.count.must eq 14
      end

      it "should contain xml elements" do
        choco_features[0].must be_an_instance_of REXML::Element
      end
    end
  end

  context "self.get_choco_feature" do
    let (:element) {  REXML::Element.new('source') }
    element_name           = "default"
    element_enabled        = "true"
    element_set_explicitly = "false"
    element_description    = "10"

    before :each do
      element.add_attributes( { "name"          => element_name,
                                "enabled"       => element_enabled,
                                "setExplicitly" => element_set_explicitly,
                                "description"   => element_description,
                              } )
    end

    it "should return nil source when element is nil" do
      @provider.get_choco_feature(nil).must be == {}
    end

    it "should convert an element to a source" do
      choco_feature = @provider.get_choco_feature(element)

      choco_feature[:name].must eq element_name
      choco_feature[:enabled].must eq element_enabled
      choco_feature[:set_explicitly].must eq element_set_explicitly
      choco_feature[:description].must eq element_description
    end
  end

  context "self.choco_features" do
    before :each do
      PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
      PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(true)
      File.expects(:read).with(choco_config).returns choco_config_contents
      herp = @provider.choco_features
    end

    it "should return an array of hashes" do
      @provider.choco_features.count.must eq 14
      @provider.choco_features[0].kind_of?(Hash)
    end
  end

  context "when installing" do
    context "with compiled choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall)
        PuppetX::Chocolatey::ChocolateyCommon.stubs(:file_exists?).with('c:\dude\config\chocolatey.config').returns(true)
        PuppetX::Chocolatey::ChocolateyCommon.stubs(:file_exists?).with('c:\dude\bin\choco.exe').returns(true)
        'c:\dude\config\chocolatey.config'
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        Puppet::Util::Execution.stubs(:execute)
      end

      it "should use install command without versioned package" do
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil)

        @provider.install
      end

      it "should call with ignore package exit codes when = 0.9.10 and not explicitly configured to use them" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(true)
        File.expects(:read).with(choco_config).returns choco_config_contents
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_choco_exit_codes).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil, '--ignore-package-exit-codes')

        @provider.install
      end

      it "should call with ignore package exit codes when > 0.9.10 and not explicitly configured to use them" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(true)
        File.expects(:read).with(choco_config).returns choco_config_contents
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil, '--ignore-package-exit-codes')

        @provider.install
      end

      it "should not ignore package exit codes when = 0.9.10 and explicitly configured to use them" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:set_env_chocolateyinstall)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_config_file).returns(choco_config)
        PuppetX::Chocolatey::ChocolateyCommon.expects(:file_exists?).with(choco_config).returns(true)
        File.expects(:read).with(choco_config).returns choco_config_contents_upec
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil)

        @provider.install
      end

      it "should use upgrade command with versioned package" do
        resource[:ensure] = '1.2.3'
        @provider.expects(:chocolatey).with('upgrade', 'chocolatey', '--version', '1.2.3', '-y', nil)

        @provider.install
      end

      it "should call install instead of upgrade if package name ends with .config" do
        resource[:name] = "packages.config"
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'packages.config','-y', nil)

        @provider.install
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('install','chocolatey','-y', '--source', 'c:\packages', nil)

        @provider.install
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
        PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns('c:\dude')
        PuppetX::Chocolatey::ChocolateyCommon.stubs(:file_exists?).with('c:\dude\bin\choco.exe').returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
      end

      it "should use install command without versioned package" do
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('install', 'chocolatey', nil)

        @provider.install
      end

      it "should use update command with versioned package" do
        resource[:ensure] = '1.2.3'
        @provider.expects(:chocolatey).with('update', 'chocolatey', '--version', '1.2.3', nil)

        @provider.install
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('install','chocolatey', '--source', 'c:\packages', nil)

        @provider.install
      end
    end
  end

  context "when holding" do
    context "with compiled choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyInstall.expects(:install_path).returns('c:\dude')
        PuppetX::Chocolatey::ChocolateyCommon.stubs(:file_exists?).with('c:\dude\bin\choco.exe').returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        Puppet::Util::Execution.stubs(:execute)
      end

      it "should use install command with held package" do
        resource[:ensure] = :held
        @provider.expects(:chocolatey).with('install', 'chocolatey','-y', nil)
        @provider.expects(:chocolatey).with('pin', 'add', '-n', 'chocolatey')

        @provider.hold
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
      end

      it "should throw an argument error with held package" do
        resource[:ensure] = :held

        expect { @provider.hold }.to raise_error(ArgumentError, "Only choco v0.9.9+ can use ensure => held")
      end
    end
  end

  context "when uninstalling" do
    context "with compiled choco client" do
      before :each do
        @provider.stubs(:is_use_package_exit_codes_feature_enabled?).returns(false)
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        Puppet::Util::Execution.stubs(:execute)
      end

      it "should call the remove operation" do
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey','-fy', nil)

        @provider.uninstall
      end

      it "should call with ignore package exit codes when = 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_choco_exit_codes).at_least_once
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey','-fy', nil, '--ignore-package-exit-codes')

        @provider.uninstall
      end

      it "should call with ignore package exit codes when > 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey','-fy', nil, '--ignore-package-exit-codes')

        @provider.uninstall
      end

      it "should use ignore source if it is specified and the version is less than 0.9.10" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey','-fy', nil)

        @provider.uninstall
      end

      it "should use source if it is specified and the version is at least 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_choco_uninstall_source).at_least_once
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey', '-fy', '--source', 'c:\packages', nil, '--ignore-package-exit-codes')

        @provider.uninstall
      end

      it "should use source if it is specified and the version is greater than 0.9.10" do
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey', '-fy', '--source', 'c:\packages', nil, '--ignore-package-exit-codes')

        @provider.uninstall
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
      end

      it "should call the remove operation" do
        @provider.expects(:chocolatey).with('uninstall', 'chocolatey', nil)

        @provider.uninstall
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('uninstall','chocolatey', '--source', 'c:\packages', nil)

        @provider.uninstall
      end
    end
  end

  context "when updating" do
    context "with compiled choco client" do
      before :each do
        @provider.stubs(:is_use_package_exit_codes_feature_enabled?).returns(false)
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        # unhold is called in installs on compiled choco
        Puppet::Util::Execution.stubs(:execute)
      end

      it "should use `chocolatey upgrade` when ensure latest and package present" do
        provider.stubs(:instances).returns [provider.new({
          :ensure   => "1.2.3",
          :name     => "chocolatey",
          :provider => :chocolatey,
        })]
        @provider.expects(:chocolatey).with('upgrade', 'chocolatey', '-y', nil)

        @provider.update
      end

      it "should call with ignore package exit codes when = 0.9.10" do
        provider.stubs(:instances).returns [provider.new({
             :ensure   => "1.2.3",
             :name     => "chocolatey",
             :provider => :chocolatey,
         })]
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(minimum_supported_choco_exit_codes).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('upgrade', 'chocolatey','-y', nil, '--ignore-package-exit-codes')

        @provider.update
      end

      it "should call with ignore package exit codes when > 0.9.10" do
        provider.stubs(:instances).returns [provider.new({
            :ensure   => "1.2.3",
            :name     => "chocolatey",
            :provider => :chocolatey,
        })]
        PuppetX::Chocolatey::ChocolateyCommon.expects(:choco_version).returns(choco_zero_ten_zero).at_least_once
        resource[:ensure] = :present
        @provider.expects(:chocolatey).with('upgrade', 'chocolatey','-y', nil, '--ignore-package-exit-codes')

        @provider.update
      end

      it "should use `chocolatey install` when ensure latest and package absent" do
        provider.stubs(:instances).returns []
        @provider.expects(:chocolatey).with('install', 'chocolatey', '-y', nil)

        @provider.update
      end

      it "should use source if it is specified" do
        provider.expects(:instances).returns [provider.new({
          :ensure   => "latest",
          :name     => "chocolatey",
          :provider => :chocolatey,
        })]
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('upgrade','chocolatey', '-y', '--source', 'c:\packages', nil)

        @provider.update
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
      end

      it "should use `chocolatey update` when ensure latest and package present" do
        provider.stubs(:instances).returns [provider.new({
          :ensure   => "1.2.3",
          :name     => "chocolatey",
          :provider => :chocolatey,
        })]
        @provider.expects(:chocolatey).with('update', 'chocolatey', nil)

        @provider.update
      end

      it "should use `chocolatey install` when ensure latest and package absent" do
        provider.stubs(:instances).returns []
        @provider.expects(:chocolatey).with('install', 'chocolatey', nil)

        @provider.update
      end

      it "should use source if it is specified" do
        provider.expects(:instances).returns [provider.new({
          :ensure   => "latest",
          :name     => "chocolatey",
          :provider => :chocolatey,
        })]
        resource[:source] = 'c:\packages'
        @provider.expects(:chocolatey).with('update','chocolatey', '--source', 'c:\packages', nil)

        @provider.update
      end
    end
  end

  context "when getting latest" do
    context "with compiled choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(true)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
      end

      it "should use choco.exe arguments" do
        # we don't care where choco is, we are concerned with the arguments that are passed to choco.
        #
        @provider.send(:latestcmd).drop(1).should == ['upgrade', '--noop', 'chocolatey','-r']
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.send(:latestcmd).drop(1).should == ['upgrade', '--noop', 'chocolatey','-r', '--source', 'c:\packages']
        #@provider.expects(:chocolatey).with('upgrade', '--noop', 'chocolatey','-r', '--source', 'c:\packages')

        #@provider.latest
      end
    end

    context "with posh choco client" do
      before :each do
        @provider.class.stubs(:is_compiled_choco?).returns(false)
        PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
      end

      it "should use posh arguments" do
        @provider.send(:latestcmd).drop(1).should == ['version', 'chocolatey', '| findstr /R "latest" | findstr /V "latestCompare"']
      end

      it "should use source if it is specified" do
        resource[:source] = 'c:\packages'
        @provider.send(:latestcmd).drop(1).should == ['version', 'chocolatey', '--source', 'c:\packages', '| findstr /R "latest" | findstr /V "latestCompare"']
        #@provider.expects(:chocolatey).with('version', 'chocolatey', '--source', 'c:\packages', '| findstr /R "latest" | findstr /V "latestCompare"')

        #@provider.latest
      end
    end
  end

  context "query" do
    it "should return a hash when chocolatey and the package are present" do
      provider.expects(:instances).returns [provider.new({
        :ensure   => "1.2.5",
        :name     => "chocolatey",
        :provider => :chocolatey,
      })]

      @provider.query.should == {
        :ensure   => "1.2.5",
        :name     => "chocolatey",
        :provider => :chocolatey,
      }
    end

    it "should return nil when the package is missing" do
      provider.expects(:instances).returns []

      @provider.query.should == nil
    end
  end

  context "when fetching a package list" do
    it "should invoke provider listcmd" do
      provider.expects(:listcmd)

      provider.instances
    end

    it "should query chocolatey" do
      provider.expects(:execpipe).with() do |args|
        args[1] =~ /list/
        args[2] =~ /-lo/
      end

      provider.instances
    end

    context "self.instances" do
      it "should return nil on error" do
        provider.expects(:execpipe).raises(Puppet::ExecutionFailure.new("ERROR!"))

        provider.instances.should be_nil
      end

      context "with compiled choco client" do
        before :each do
          @provider.class.stubs(:is_compiled_choco?).returns(true)
          PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(first_compiled_choco_version)
        end

        it "should return installed packages with their versions" do
          provider.expects(:execpipe).yields(StringIO.new(%Q(package1|1.23\n\package2|2.00\n)))

          packages = (provider.instances)

          packages.length.should == 2

          packages[0].properties.should == {
              :provider => :chocolatey,
              :ensure => "1.23",
              :name => 'package1'
          }

          packages[1].properties.should == {
              :provider => :chocolatey,
              :ensure => "2.00",
              :name => 'package2'
          }
        end

        it "should return nil on error" do
          provider.expects(:execpipe).yields(StringIO.new(%Q(Unable to search for packages when there are no soures enabled for packages and none were passed as arguments.\n)))

          expect {
            provider.instances
          }.to raise_error(Puppet::Error, /At least one source must be enabled./)
        end
      end

      context "with posh choco client" do
        before :each do
          @provider.class.stubs(:is_compiled_choco?).returns(false)
          PuppetX::Chocolatey::ChocolateyVersion.stubs(:version).returns(last_posh_choco_version)
        end

        it "should return installed packages with their versions" do
          provider.expects(:execpipe).yields(StringIO.new(%Q(package1 1.23\n\package2 2.00\n)))

          packages = (provider.instances)

          packages.length.should == 2

          packages[0].properties.should == {
              :provider => :chocolatey,
              :ensure => "1.23",
              :name => 'package1'
          }

          packages[1].properties.should == {
              :provider => :chocolatey,
              :ensure => "2.00",
              :name => 'package2'
          }
        end
      end
    end
  end
end
