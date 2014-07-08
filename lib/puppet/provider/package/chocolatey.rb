# authored by Rich Siegel (rismoney@gmail.com)
# with help from some of the other pkg providers of course

require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:chocolatey, :parent => Puppet::Provider::Package) do
  desc "Package management using Chocolatey on Windows"
  confine    :operatingsystem => :windows

  has_feature :installable, :uninstallable, :upgradeable, :versionable, :install_options


  def self.chocolatey_command
    chocopath = ENV['ChocolateyInstall'] || ('C:\Chocolatey' if File.directory?('C:\Chocolatey')) || 'C:\ProgramData\chocolatey'

    chocopath + "\\chocolateyInstall\\chocolatey.cmd"
  end

  commands :chocolatey => chocolatey_command

 def print()
   notice("The value is: '${name}'")
 end

  def install
    should = @resource.should(:ensure)
    case should
    when true, false, Symbol
      args = "install", @resource[:name][/\A\S*/], resource[:install_options]
    else
      # Add the package version
      args = "install", @resource[:name][/\A\S*/], "-version", resource[:ensure], resource[:install_options]
    end

    if @resource[:source]
      args << "-source" << resource[:source]
    end

    chocolatey(*args)
  end

  def uninstall
    args = "uninstall", @resource[:name][/\A\S*/]
    chocolatey(*args)
  end

  def update
    args = "update", @resource[:name][/\A\S*/], resource[:install_options]

    if @resource[:source]
      args << "-source" << resource[:source]
    end

    chocolatey(*args)
  end

  # from puppet-dev mailing list
  # Puppet will call the query method on the instance of the package
  # provider resource when checking if the package is installed already or
  # not.
  # It's a determination for one specific package, the package modeled by
  # the resource the method is called on.
  # Query provides the information for the single package identified by @Resource[:name].

  def query
    self.class.instances.each do |provider_chocolatey|
      return provider_chocolatey.properties if @resource[:name][/\A\S*/] == provider_chocolatey.name
    end
    return nil
  end

  def self.listcmd
    [command(:chocolatey), "list", "-lo"]
  end

  def self.instances
    packages = []

    begin
      execpipe(listcmd()) do |process|
        process.each_line do |line|
          line.chomp!
          if line.empty? or line.match(/Reading environment variables.*/); next; end
          values = line.split(' ')
          packages << new({ :name => values[0], :ensure => values[1], :provider => self.name })
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end
    packages
  end

  def latestcmd
    [command(:chocolatey), ' version ' + @resource[:name][/\A\S*/] + ' | findstr /R "latest" | findstr /V "latestCompare" ']
  end

  def latest
    packages = []

    begin
      output = execpipe(latestcmd()) do |process|

        process.each_line do |line|
          line.chomp!
          if line.empty?; next; end
          # Example: ( latest        : 2013.08.19.155043 )
          values = line.split(':').collect(&:strip).delete_if(&:empty?)
          return values[1]
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end
    packages
  end

end
