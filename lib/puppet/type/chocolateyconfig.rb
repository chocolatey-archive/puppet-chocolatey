require 'puppet/type'
require 'pathname'

Puppet::Type.newtype(:chocolateyconfig) do
  @doc = <<-DOC
    Allows managing config settings for Chocolatey.
    Configuration values provide settings for users
    to configure aspects of Chocolatey and the way it
    functions. Similar to features, except allow for user
    configured values. Requires 0.9.10+. Learn more about
    config at https://chocolatey.org/docs/commands-config
  DOC

  ensurable do
    desc 'Specifies state of resource'

    newvalue(:present)  { provider.create }
    newvalue(:absent)   { provider.destroy }
    defaultto :present

    def retrieve
      provider.properties[:ensure]
    end
  end

  newparam(:name) do
    desc "The name of the config setting. Used for uniqueness.
      Puppet is not able to easily manage any values that
      include Password in the key name in them as they
      will be encrypted in the configuration file."

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

  newproperty(:value) do
    desc "The value of the config setting. If the
      name includes 'password', then the value is
      not ensurable due to being encrypted in the
      configuration file."

    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty value must be specified. To unset value, use ensure => absent'
      end
    end

    def insync?(is)
      if resource[:name] =~ %r{password}i
        # If name contains password, it is
        # always in sync if there is a value
        (is.nil? || is.empty?) == (should.nil? || should.empty?)
      else
        is.casecmp(should.downcase).zero?
      end
    end
  end

  validate do
    if provider.respond_to?(:validate)
      provider.validate
    end
  end

  autorequire(:exec) do
    ['install_chocolatey_official']
  end
end
