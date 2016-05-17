require 'puppet/type'
require 'pathname'
require 'rexml/document'

Puppet::Type.type(:chocolateysource).provide(:windows) do
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  require Pathname.new(__FILE__).dirname + '../../../' + 'puppet_x/chocolatey/chocolatey_common'
  include PuppetX::Chocolatey::ChocolateyCommon

  MINIMUM_SUPPORTED_CHOCO_VERSION = '0.9.9.0'
  MINIMUM_SUPPORTED_CHOCO_VERSION_PRIORITY = '0.9.9.9'

  commands :chocolatey => PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def properties
    if @property_hash.empty?
      @property_hash = query || { :ensure => ( :absent )}
      @property_hash[:ensure] = :absent if @property_hash.empty?
    end
    @property_hash.dup
  end

  def query
    self.class.sources.each do |source|
      return source.properties if @resource[:name][/\A\S*/].downcase == source.name.downcase
    end

    return {}
  end

  def self.get_sources
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall

    choco_config = PuppetX::Chocolatey::ChocolateyCommon.choco_config_file
    raise Puppet::ResourceError, "Config file not found for Chocolatey. Please make sure you have Chocolatey installed." if choco_config.nil?
    raise Puppet::ResourceError, "An install was detected, but was unable to locate config file at #{choco_config}." unless PuppetX::Chocolatey::ChocolateyCommon.file_exists?(choco_config)

    Puppet.debug("Gathering sources from '#{choco_config}'.")
    config = REXML::Document.new File.new(choco_config, 'r')

    config.elements.to_a( '//source' )
  end

  def self.get_source(element)
    source = {}
    return source if element.nil?

    source[:name] = element.attributes['id'].downcase if element.attributes['id']
    source[:location] = element.attributes['value'].downcase if element.attributes['value']

    disabled = false
    disabled = element.attributes['disabled'].downcase == 'true' if element.attributes['disabled']
    source[:ensure] = :present
    source[:ensure] = :disabled if disabled

    source[:priority] = 0
    source[:priority] = element.attributes['priority'].downcase if element.attributes['priority']

    source[:user] = element.attributes['user'].downcase if element.attributes['user']

    Puppet.debug("Loaded source '#{source.inspect}'.")

    source
  end

  def self.sources
    @sources ||=  get_sources.collect do |item|
      source = get_source(item)
      new(source)
    end
  end

  def self.refresh_sources
    @sources = nil
    self.sources
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
    if choco_version < Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION)
      raise Puppet::ResourceError, "Chocolatey version must be '#{MINIMUM_SUPPORTED_CHOCO_VERSION}' to manage configuration values with Puppet. Detected '#{choco_version}' as your version. Please upgrade Chocolatey to use this resource."
    end

    if choco_version < Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_PRIORITY) && resource[:priority] && resource[:priority] != 0
      Puppet.warning("Chocolatey is unable to manage priority for sources when version is less than #{MINIMUM_SUPPORTED_CHOCO_VERSION_PRIORITY}. The value you set will be ignored.")
    end

    if resource[:password] && resource[:password] != ''
      Puppet.debug("The password is not ensurable, so Puppet is unable to change the value using chocolateysource resource. As a workaround, a password change can be in the form of an exec. Reference Chocolateysource[#{resource[:name]}]")
    end
  end

  mk_resource_methods

  def flush
    args = []
    args << 'source'

    command = 'add'
    command = 'remove' if @property_flush[:ensure] == :absent

    args << command
    args << '--name' << resource[:name]

    if @property_flush[:ensure] != :absent
      args << '--source' << resource[:location]

      choco_gem_version = Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version)

      if resource[:user]  && resource[:user] != ''
        args << '--user' << resource[:user]
        args << '--password' << resource[:password]
      end

      if choco_gem_version >= Gem::Version.new(MINIMUM_SUPPORTED_CHOCO_VERSION_PRIORITY)
        args << '--priority' << (resource[:priority] || 0)
      end
    end

    begin
      Puppet::Util::Execution.execute([command(:chocolatey), *args])
    rescue Puppet::ExecutionFailure
      raise Puppet::Error, "An error occurred running choco. Unable to set Chocolatey source configuration for #{self.inspect}"
    end

    if @property_flush[:ensure] != :absent
      command = 'enable'
      command = 'disable' if @property_flush[:ensure] == :disabled
      begin
        Puppet::Util::Execution.execute([command(:chocolatey), 'source', command, '--name', resource[:name]])
      rescue Puppet::ExecutionFailure
        raise Puppet::Error, "An error occurred running choco. Unable to set Chocolatey source configuration for #{self.inspect}"
      end
    end

    @property_hash.clear
    @property_hash = { :ensure => ( @property_flush[:ensure] )}  #if  @property_flush[:ensure] == :absent

    @property_flush.clear

    self.class.refresh_sources
    @property_hash = query
  end

end
