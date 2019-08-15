require 'puppet/type'
require 'pathname'

Puppet::Type.newtype(:chocolateysource) do
  @doc = <<-'EOT'
    Allows managing sources for Chocolatey. A source can be a
    folder, a CIFS share, a NuGet Http OData feed, or a full
    Package Gallery. Learn more about sources at
    https://chocolatey.org/docs/how-to-host-feed

  EOT

  ensurable do
    desc 'Specifies state of resource'

    newvalue(:present)  { provider.create }
    newvalue(:disabled) { provider.disable }
    newvalue(:absent)   { provider.destroy }
    defaultto :present

    def retrieve
      provider.properties[:ensure]
    end
  end

  newparam(:name) do
    desc 'The name of the source. Used for uniqueness.'

    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty name must be specified.'
      end
    end

    isnamevar

    munge do |value|
      value.downcase
    end

    def insync?(is)
      is.casecmp(should.downcase).zero?
    end
  end

  newproperty(:location) do
    desc "The location of the source repository. Can be a url pointing to
      an OData feed (like chocolatey/chocolatey_server), a CIFS (UNC) share,
      or a local folder. Required when `ensure => present` (the default for
      `ensure`)."

    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty location must be specified.'
      end
    end

    def insync?(is)
      is.casecmp(should.downcase).zero?
    end
  end

  newproperty(:user) do
    desc "Optional user name for authenticated feeds.
      Requires at least Chocolatey v0.9.9.0.
      Defaults to `nil`. Specifying an empty value is the
      same as setting the value to nil or not specifying
      the property at all."

    def insync?(is)
      is.casecmp(should.downcase).zero?
    end

    defaultto ''
  end

  newparam(:password) do
    desc "Optional user password for authenticated feeds.
      Not ensurable. Value is not able to be checked
      with current value. If you need to update the password,
      update another setting as well.
      Requires at least Chocolatey v0.9.9.0.
      Defaults to `nil`. Specifying an empty value is the
      same as setting the value to nil or not specifying
      the property at all."

    defaultto ''
  end

  newproperty(:priority) do
    desc "Optional priority for explicit feed order when
      searching for packages across multiple feeds.
      The lower the number the higher the priority.
      Sources with a 0 priority are considered no priority
      and are added after other sources with a priority
      number.
      Requires at least Chocolatey v0.9.9.9.
      Defaults to 0."

    validate do |value|
      if value.nil?
        raise ArgumentError, 'A non-empty priority must be specified.'
      end
      raise ArgumentError, 'An integer is necessary for priority. Specify 0 or remove for no priority.' unless resource.numeric?(value)
    end

    # There is a slight bug in the way that Puppet::Util::Execution.execute
    # handles parameters if you specify that the command to execute is sensitive.
    # When sensitive is not specified all parameters are cast to strings. If
    # Sensitive is specified then paramters retain their types. In this case it
    # means that if :priority is allowed to remain an integer it will cause a
    # failure later in the Puppet::Util::Execution.execute_windows method that
    # assumes all parameters in the `command` array it recieives will be strings.
    # This munge has no effect on the commandline that eventually gets generated.
    munge do |value|
      resource.munge_to_string(value)
    end

    defaultto('0')
  end

  newproperty(:bypass_proxy, boolean: true) do
    desc "Option to specify whether this source should
      explicitly bypass any explicitly or system
      configured proxies.
      Requires at least Chocolatey v0.10.4.
      Defaults to false."

    newvalues(:true, :false)
    defaultto(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:admin_only, boolean: true) do
    desc "Option to specify whether this source should
      visible to Windows user accounts in the Administrators
      group only.

      Requires Chocolatey for Business (C4B) v1.12.2+ and at
      least Chocolatey v0.10.8 for the setting to be respected.
      Defaults to false."

    newvalues(:true, :false)
    defaultto(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:allow_self_service, boolean: true) do
    desc "Option to specify whether this source should be
      allowed to be used with Chocolatey Self Service.

      Requires Chocolatey for Business (C4B) v1.10.0+ with the
      feature useBackgroundServiceWithSelfServiceSourcesOnly
      turned on in order to be respected.
      Also requires at least Chocolatey v0.10.4 for the setting
      to be enabled.
      Defaults to false."

    newvalues(:true, :false)
    defaultto(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  validate do
    if (!self[:user].nil? && self[:user].strip != '' && (self[:password].nil? || self[:password] == '')) ||
       ((self[:user].nil? || self[:user].strip == '') && !self[:password].nil? && self[:password] != '')
      raise ArgumentError, 'If specifying user/password, you must specify both values.'
    end

    if provider.respond_to?(:validate)
      provider.validate
    end
  end

  autorequire(:exec) do
    ['install_chocolatey_official']
  end

  def munge_boolean(value)
    case value
    when true, 'true', :true
      :true
    when false, 'false', :false
      :false
    else
      raise('munge_boolean only takes booleans')
    end
  end

  def munge_to_string(value)
    case value.class
    when String
      value
    else
      value.to_s
    end
  end

  def numeric?(value)
    # this is what stdlib does. Not sure if we want to emulate or not.
    # numeric = %r{^-?(?:(?:[1-9]\d*)|0)$}
    # if value.is_a? Integer or (value.is_a? String and value.match numeric)

    !Float(value).nil?
  rescue
    false
  end

  def set_sensitive_parameters(sensitive_parameters) # rubocop:disable Style/AccessorMethodName
    parameter(:password).sensitive = true if parameter(:password)
    super(sensitive_parameters)
  end
end
