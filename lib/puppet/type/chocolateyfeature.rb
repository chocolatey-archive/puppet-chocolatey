require 'puppet/type'
require 'pathname'

Puppet::Type.newtype(:chocolateyfeature) do
  @doc = <<-'EOT'
    Allows managing features for Chocolatey. Features are
    configuration that act as feature flippers to turn on or
    off certain aspects of how Chocolatey works.
    Learn more about features at
    https://chocolatey.org/docs/commands-feature

  EOT

  newparam(:name) do
    desc 'The name of the feature. Used for uniqueness.'

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

  ensurable do
    desc 'Specifies state of resource'

    newvalue(:enabled)  { provider.enable }
    newvalue(:disabled) { provider.disable }

    def retrieve
      provider.properties[:ensure]
    end
  end

  validate do
    if self[:ensure].nil? && provider.properties[:ensure].nil?
      raise ArgumentError, 'Invalid value for ensure. Valid values are enabled or disabled.'
    end

    if provider.respond_to?(:validate)
      provider.validate
    end
  end

  autorequire(:exec) do
    ['install_chocolatey_official']
  end
end
