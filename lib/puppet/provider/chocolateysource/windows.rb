require 'puppet/type'
require 'pathname'
require 'rexml/document'

Puppet::Type.type(:chocolateysource).provide(:windows) do
  @doc = 'Windows based provider for chocolateysource type.'

  confine operatingsystem: :windows
  defaultfor operatingsystem: :windows

  require Pathname.new(__FILE__).dirname + '../../../' + 'puppet_x/chocolatey/chocolatey_common'
  include PuppetX::Chocolatey::ChocolateyCommon

  MINIMUM_SUPPORTED_CHOCO_VERSION = '0.9.9.0'.freeze
  MINIMUM_SUPPORTED_CHOCO_VERSION_PRIORITY = '0.9.9.9'.freeze
  MINIMUM_SUPPORTED_CHOCO_VERSION_BYPASS_PROXY = '0.10.4'.freeze
  MINIMUM_SUPPORTED_CHOCO_VERSION_ALLOW_SELF_SERVICE = '0.10.4'.freeze
  MINIMUM_SUPPORTED_CHOCO_VERSION_ADMIN_ONLY = '0.10.8'.freeze

  commands chocolatey: PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def properties
    if @property_hash.empty?
      @property_hash = query || { ensure: :absent }
      @property_hash[:ensure] = :absent if @property_hash.empty?
    end
    @property_hash.dup
  end

  def query
    self.class.sources.each do |source|
      return source.properties if @resource[:name][%r{\A\S*}].casecmp(source.name.downcase).zero?
    end

    {}
  end

  def self.read_sources
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall

    choco_config = PuppetX::Chocolatey::ChocolateyCommon.choco_config_file
    raise Puppet::ResourceError, 'Config file not found for Chocolatey. Please make sure you have Chocolatey installed.' if choco_config.nil?
    raise Puppet::ResourceError, "An install was detected, but was unable to locate config file at #{choco_config}." unless PuppetX::Chocolatey::ChocolateyCommon.file_exists?(choco_config)

    Puppet.debug("Gathering sources from '#{choco_config}'.")
    config = REXML::Document.new File.read(choco_config)

    config.elements.to_a('//source')
  end

  def self.get_source(element)
    source = {}
    return source if element.nil?

    source[:name] = element.attributes['id'].downcase if element.attributes['id']
    source[:location] = element.attributes['value'].downcase if element.attributes['value']

    disabled = false
    disabled = element.attributes['disabled'].casecmp('true').zero? if element.attributes['disabled']
    source[:ensure] = :present
    source[:ensure] = :disabled if disabled

    source[:priority] = '0'
    source[:priority] = element.attributes['priority'].downcase if element.attributes['priority']

    source[:bypass_proxy] = false
    source[:bypass_proxy] = element.attributes['bypassProxy'].downcase if element.attributes['bypassProxy']

    source[:admin_only] = false
    source[:admin_only] = element.attributes['adminOnly'].downcase if element.attributes['adminOnly']

    source[:allow_self_service] = false
    source[:allow_self_service] = element.attributes['selfService'].downcase if element.attributes['selfService']

    source[:user] = ''
    source[:user] = element.attributes['user'].downcase if element.attributes['user']

    Puppet.debug("Loaded source '#{source.inspect}'.")

    source
  end

  def self.sources
    @sources ||= read_sources.map do |item|
      source = get_source(item)
      new(source)
    end
  end

  def self.refresh_sources
    @sources = nil
    sources
  end

  def self.instances
    sources
  end

  def self.prefetch(resources)
    instances.each do |provider|
      if (resource = resources[provider.name])
        resource.provider = provider
      end
    end
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def disable
    @property_flush[:ensure] = :disabled
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def validate
    choco_version = Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version)
    if PuppetX::Chocolatey::ChocolateyCommon.file_exists?(PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command) && choco_version < Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION)
      raise Puppet::ResourceError, "Chocolatey version must be '#{MINIMUM_SUPPORTED_CHOCO_VERSION}' to manage configuration values with Puppet. "\
        "Detected '#{choco_version}' as your version. Please upgrade Chocolatey to use this resource."
    end

    if choco_version < Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_PRIORITY) && resource[:priority] && resource[:priority] != '0'
      Puppet.warning("Chocolatey is unable to manage priority for sources when version is less than #{MINIMUM_SUPPORTED_CHOCO_VERSION_PRIORITY}. The value you set will be ignored.")
    end

    if choco_version < Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_BYPASS_PROXY) && resource[:bypass_proxy] && resource[:bypass_proxy] != :false
      Puppet.warning("Chocolatey is unable to specify bypassing system proxy for sources when version is less than #{MINIMUM_SUPPORTED_CHOCO_VERSION_BYPASS_PROXY}. The value you set will be ignored.")
    end

    if choco_version < Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_ALLOW_SELF_SERVICE) && resource[:allow_self_service] && resource[:allow_self_service] != :false
      Puppet.warning("Chocolatey is unable to specify self-service for sources when version is less than #{MINIMUM_SUPPORTED_CHOCO_VERSION_ALLOW_SELF_SERVICE}. The value you set will be ignored.")
    end

    if choco_version < Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_ADMIN_ONLY) && resource[:admin_only] && resource[:admin_only] != :false
      Puppet.warning("Chocolatey is unable to specify administrator only visibility for sources when version is less than #{MINIMUM_SUPPORTED_CHOCO_VERSION_ADMIN_ONLY}. "\
        'The value you set will be ignored.')
    end

    # location is always filled in with puppet resource, but
    # resource[:location] is always empty (because it has a different
    # code path where validation occurs before all properties/params
    # have been set), resulting in errors
    # location is always :absent when a manifest runs this with a missing
    # `location => value`
    location_check = location
    # location could be :absent, which mk_resource_method will set it to
    # resource[:location] is nil when running puppet resource
    # if you remove `location => value`
    location_check = resource[:location] if location_check == :absent
    if resource[:ensure] == :present && (location_check.nil? || location_check.strip == '')
      raise ArgumentError, 'A non-empty location must be specified when ensure => present.'
    end

    if resource[:password] && resource[:password] != '' # rubocop:disable Style/GuardClause
      Puppet.debug('The password is not ensurable, so Puppet is unable to change the value using chocolateysource resource. '\
        "As a workaround, a password change can be in the form of an exec. Reference Chocolateysource[#{resource[:name]}]")
    end
  end

  mk_resource_methods

  def flush
    args = []
    opts = {}

    args << 'source'

    # look at the hash, then flush if present.
    # If all else fails, looks at resource[:ensure]
    property_ensure = @property_hash[:ensure]
    property_ensure = @property_flush[:ensure] if @property_flush[:ensure]
    property_ensure = resource[:ensure] if property_ensure.nil?

    command = 'add'
    command = 'remove' if property_ensure == :absent
    command = 'disable' if property_ensure == :disabled

    args << command
    args << '--name' << resource[:name]

    if command == 'add'
      args << '--source' << resource[:location]

      if resource[:user] && resource[:user] != ''
        args << '--user' << resource[:user]
        args << '--password' << resource[:password]
        opts = { sensitive: true, failonfail: true, combine: true }
      end

      choco_gem_version = Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version)
      if choco_gem_version >= Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_BYPASS_PROXY)
        args << '--bypass-proxy' if resource[:bypass_proxy].to_s == 'true'
      end

      if choco_gem_version >= Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_ALLOW_SELF_SERVICE)
        args << '--allow-self-service' if resource[:allow_self_service] == :true
      end

      if choco_gem_version >= Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_ADMIN_ONLY)
        args << '--admin-only' if resource[:admin_only].to_s == 'true'
      end

      if choco_gem_version >= Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_PRIORITY)
        args << '--priority' << resource[:priority]
      end
    end

    begin
      Puppet::Util::Execution.execute([command(:chocolatey), *args], opts)
    rescue Puppet::ExecutionFailure
      raise Puppet::Error, "An error occurred running choco. Unable to set Chocolatey source configuration for #{inspect}"
    end

    if property_ensure == :present
      begin
        Puppet::Util::Execution.execute([command(:chocolatey), 'source', 'enable', '--name', resource[:name]])
      rescue Puppet::ExecutionFailure
        raise Puppet::Error, "An error occurred running choco. Unable to set Chocolatey source configuration for #{inspect}"
      end
    end

    @property_hash.clear
    @property_flush.clear

    self.class.refresh_sources
    @property_hash = query
  end
end
