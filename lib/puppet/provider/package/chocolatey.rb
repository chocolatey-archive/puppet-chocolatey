# frozen_string_literal: true

require 'puppet/provider/package'
require 'pathname'
require 'rexml/document'
require Pathname.new(__FILE__).dirname + '../../../' + 'puppet_x/chocolatey/chocolatey_install'

Puppet::Type.type(:package).provide(:chocolatey, parent: Puppet::Provider::Package) do
  desc "Manages packages using Chocolatey (Windows package manager).

    The syntax for Chocolatey using the puppet provider is a much
    closer match to *nix package managers, bringing a more agnostic
    approach to package management across platforms. Chocolatey packages
    usually contain all of the logic to install software silently on a
    Windows machine, much like RPM (yum) or DPKG (apt).

    Installs can be as simple as

      package {'git':
        ensure => latest,
      }

    See the ReadMe for more information."

  confine     operatingsystem: :windows
  has_feature :installable
  has_feature :uninstallable
  has_feature :upgradeable
  has_feature :versionable
  has_feature :install_options
  has_feature :uninstall_options
  has_feature :holdable
  has_feature :package_settings
  has_feature :version_ranges

  if Puppet::Util::Platform.windows?
    require 'puppet/util/package/version/range'
    require 'puppet/util/package/version/gem'
  end

  require Pathname.new(__FILE__).dirname + '../../../' + 'puppet_x/chocolatey/chocolatey_common'
  include PuppetX::Chocolatey::ChocolateyCommon

  commands chocolatey: PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command

  def initialize(value = {})
    super(value)
  end

  def print
    notice("The value is: '${name}'")
  end

  def self.compiled_choco?
    Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version) >= Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon::FIRST_COMPILED_CHOCO_VERSION)
  end

  def compiled_choco?
    self.class.compiled_choco?
  end

  def read_choco_features
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall

    choco_config = PuppetX::Chocolatey::ChocolateyCommon.choco_config_file
    raise Puppet::ResourceError, 'Config file not found for Chocolatey. Please make sure you have Chocolatey installed.' if choco_config.nil?
    raise Puppet::ResourceError, "An install was detected, but was unable to locate config file at #{choco_config}." unless PuppetX::Chocolatey::ChocolateyCommon.file_exists?(choco_config)

    Puppet.debug("Gathering sources from '#{choco_config}'.")
    config = REXML::Document.new File.read(choco_config)

    config.elements.to_a('//feature')
  end

  def get_choco_feature(element)
    feature = {}
    return feature if element.nil?

    feature[:name]           = element.attributes['name'].downcase if element.attributes['name']
    feature[:enabled]        = element.attributes['enabled'].downcase if element.attributes['enabled']
    feature[:set_explicitly] = element.attributes['setExplicitly'].downcase if element.attributes['setExplicitly']
    feature[:description]    = element.attributes['description'].downcase if element.attributes['description']

    Puppet.debug("Loaded feature '#{feature.inspect}'.")

    feature
  end

  def choco_features
    @choco_features ||= read_choco_features.map do |item|
      get_choco_feature(item)
    end
  end

  def use_package_exit_codes_feature_enabled?
    use_package_exit_codes_feature = choco_features.find { |choco_feature| choco_feature[:name] == 'usepackageexitcodes' }
    return false if use_package_exit_codes_feature.nil?
    # Verifies that the feature has been explicitly set - true is the default value,
    # but implementing this without an explicit check would break existing users.
    # This is unlikely to work because Puppet itself will not know how to handle these
    # alternate exit codes.
    return true if use_package_exit_codes_feature[:enabled].casecmp('true').zero? && use_package_exit_codes_feature[:set_explicitly].casecmp('true').zero?
    false
  end

  def install
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall
    choco_exe = compiled_choco?

    args = []

    # also will need to address -sidebyside or -m in the install args to allow
    # multiple versions to be installed.
    args << 'install'

    should = @resource.should(:ensure)

    if should.is_a?(String)
      begin
        should_range = GEM_VERSION_RANGE.parse(should, GEM_VERSION)
        unless should_range.is_a?(VersionRange::Eq)
          should = best_version(should_range)
          @resource[:ensure] = should
        end
      rescue VersionRange::ValidationFailure, DebianVersion::ValidationFailure
        Puppet.debug("Cannot parse #{should} as a debian version range, falling through")
      end
    end

    case should
    when true, false, Symbol
      args << @resource[:name][%r{\A\S*}]
    else
      args.clear
      args << if choco_exe
                'upgrade'
              else
                'update'
              end

      # Add the package version
      args << @resource[:name][%r{\A\S*}] << '--version' << should
    end

    if choco_exe
      args << '-y'
    end

    if @resource[:source]
      args << '--source' << @resource[:source]
    end

    args << @resource[:install_options]

    if Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version) >= Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon::MINIMUM_SUPPORTED_CHOCO_VERSION_EXIT_CODES) &&
       !use_package_exit_codes_feature_enabled?
      args << '--ignore-package-exit-codes'
    end

    @resource[:package_settings] ||= {}
    if @resource[:package_settings]['verbose']
      Puppet.info 'Calling chocolatey with arguments: ' + args.join(' ')
    elsif Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version) >= Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon::MINIMUM_SUPPORTED_CHOCO_VERSION_NO_PROGRESS)
      args << '--no-progress'
    end
    output = chocolatey(*args)
    Puppet.info 'Output from chocolatey: ' + output if @resource[:package_settings]['log_output']
  end

  def uninstall
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall
    choco_exe = compiled_choco?

    # unhold on uninstall if package is on hold
    unhold if on_hold?

    args = 'uninstall', @resource[:name][%r{\A\S*}]

    if choco_exe
      args << '-fy'
    end

    choco_version = Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version)
    if !choco_exe || choco_version >= Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon::MINIMUM_SUPPORTED_CHOCO_UNINSTALL_SOURCE)
      if @resource[:source]
        args << '--source' << @resource[:source]
      end
    end

    args << @resource[:uninstall_options]

    if Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version) >= Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon::MINIMUM_SUPPORTED_CHOCO_VERSION_EXIT_CODES) &&
       !use_package_exit_codes_feature_enabled?
      args << '--ignore-package-exit-codes'
    end

    @resource[:package_settings] ||= {}
    Puppet.info 'Calling chocolatey with arguments: ' + args.join(' ') if @resource[:package_settings]['verbose']
    output = chocolatey(*args)
    Puppet.info 'Output from chocolatey: ' + output if @resource[:package_settings]['log_output']
  end

  def update
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall
    choco_exe = compiled_choco?

    # unhold on upgrade if package is on hold
    unhold if on_hold?

    args = []

    if choco_exe
      args << 'upgrade' << @resource[:name][%r{\A\S*}] << '-y'
    else
      args << 'update' << @resource[:name][%r{\A\S*}]
    end

    if @resource[:source]
      args << '--source' << @resource[:source]
    end

    args << @resource[:install_options]

    if Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version) >= Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon::MINIMUM_SUPPORTED_CHOCO_VERSION_EXIT_CODES) &&
       !use_package_exit_codes_feature_enabled?
      args << '--ignore-package-exit-codes'
    end

    if query
      @resource[:package_settings] ||= {}
      if @resource[:package_settings]['verbose']
        Puppet.info 'Calling chocolatey with arguments: ' + args.join(' ')
      elsif Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version) >= Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon::MINIMUM_SUPPORTED_CHOCO_VERSION_NO_PROGRESS)
        args << '--no-progress'
      end
      output = chocolatey(*args)
      if @resource[:package_settings]['log_output']
        Puppet.info 'Output from chocolatey: ' + output
      end
    else
      install
    end
  end

  # from puppet-dev mailing list
  # Puppet will call the query method on the instance of the package
  # provider resource when checking if the package is installed already or
  # not.
  # It's a determination for one specific package, the package modeled by
  # the resource the method is called on.
  # Query provides the information for the single package identified by @Resource[:name].
  def query
    self.class.instances.each do |package|
      return package.properties if @resource[:name][%r{\A\S*}].casecmp(package.name.downcase).zero?
    end

    nil
  end

  def self.listcmd
    args = []
    args << 'list'
    args << '-lo'
    if compiled_choco?
      args << '-r'
    end

    [command(:chocolatey), *args]
  end

  def self.instances
    packages = []
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall
    choco_exe = compiled_choco?
    begin
      pins = []
      pin_output = nil unless choco_exe
      # don't add -r yet, as there is an issue in 0.9.9.9/0.9.9.10 that returns full list plus pins
      pin_output = Puppet::Util::Execution.execute([command(:chocolatey), 'pin', 'list']) if choco_exe
      pin_output&.split("\n")&.each { |pin| pins << pin.split('|')[0] }

      execpipe(listcmd) do |process|
        process.each_line do |line|
          line.chomp!
          next if line.empty? || line.match(%r{Reading environment variables.*})
          raise Puppet::Error, 'At least one source must be enabled.' if line.match?(%r{Unable to search for packages.*})
          values = if choco_exe
                     line.split('|')
                   else
                     line.split(' ')
                   end
          package = {
            name: values[0].downcase,
            ensure: values[1],
            provider: name
          }
          package[:mark] = :hold if pins.include? package[:name]
          packages << new(package)
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end

    packages
  end

  def latestcmd
    choco_exe = compiled_choco?
    args = []
    args = if choco_exe
             args << 'upgrade' << '--noop' << @resource[:name][%r{\A\S*}] << '-r'
           else
             args << 'version' << @resource[:name][%r{\A\S*}]
           end

    if @resource[:source]
      args << '--source' << @resource[:source]
    end

    unless choco_exe
      args << '| findstr /R "latest" | findstr /V "latestCompare"'
    end
    @resource[:package_settings] ||= {}
    if @resource[:package_settings]['verbose']
      Puppet.info 'Calling chocolatey with arguments: ' + args.join(' ')
    end
    [command(:chocolatey), *args]
  end

  def latest
    package_ver = ''
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall
    begin
      execpipe(latestcmd) do |process|
        process.each_line do |line|
          line.chomp!
          next if line.empty?
          if compiled_choco?
            values = line.split('|')
            package_ver = values[2]
          else
            # Example: ( latest        : 2013.08.19.155043 )
            values = line.split(':').map(&:strip).delete_if(&:empty?)
            package_ver = values[1]
          end
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end

    package_ver
  end

  def deprecated_hold
    raise ArgumentError, 'Only choco v0.9.9+ can use ensure => held' unless compiled_choco?

    install

    hold
  end

  def hold
    args = 'pin', 'add', '-n', @resource[:name][%r{\A\S*}]

    chocolatey(*args)
  end

  def unhold
    return unless compiled_choco?

    args = 'pin', 'remove', '-n', @resource[:name][%r{\A\S*}]

    chocolatey(*args)
  end

  def on_hold?
    return false unless compiled_choco?
    properties[:mark] == :hold
  end

  def package_settings
    # Not actually used
  end

  def package_settings=
    # Not actually used
  end

  def package_settings_insync?(_should, _is)
    true
  end

  def version_range?(value)
    GEM_VERSION_RANGE.parse(value, GEM_VERSION)
    true
  rescue
    false
  end

  def insync?(is)
    # this is called after the generic version matching logic (insync? for the
    # type), so we only get here if should != is
    return false unless is && is != :absent
    # if 'should' is a range and 'is' a gem version we should check if 'should' includes 'is'
    should = @resource[:ensure]
    return false unless is.is_a?(String) && should.is_a?(String)
    return false unless version_range?(should)
    should_range = GEM_VERSION_RANGE.parse(should, GEM_VERSION)
    should_range.include?(GEM_VERSION.parse(is))
  end

  def all_versions_cmd
    choco_exe = compiled_choco?
    args = [
      'list',
      @resource[:name][%r{\A\S*}],
      '-a',
    ]

    args << '-r' if choco_exe
    if @resource[:source]
      args << '--source' << @resource[:source]
    end
    [command(:chocolatey), *args]
  end

  def best_version(should_range)
    # Get all available versions from chocolatey which are matching the defined version range and return the highest.
    available_versions = SortedSet.new
    execpipe(all_versions_cmd) do |process|
      process.each_line do |line|
        line.chomp!
        next if line.empty?
        if compiled_choco?
          values = line.split('|')
          package_ver = GEM_VERSION.parse(values[1])
        else
          # Example: ( latest        : 2013.08.19.155043 )
          values = line.split(':').map(&:strip).delete_if(&:empty?)
          package_ver = values[1]
        end
        available_versions << package_ver if should_range.include?(package_ver)
      end
    end

    raise Puppet::Error, 'No available version found that match given version range.' if available_versions.empty?
    available_versions.to_a.last.to_s
  end
end
