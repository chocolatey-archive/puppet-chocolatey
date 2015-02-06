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

    if @resource[:source]
      args << "-source" << resource[:source]
    end

    chocolatey(*args)
  end

  def update
    args = "update", @resource[:name][/\A\S*/], resource[:install_options]

    if @resource[:source]
      args << "-source" << resource[:source]
    end

    if self.query
      chocolatey(*args)
    else
      self.install
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
    if @resource[:source] == 'webpi'
      begin
        in_list = false
        execpipe([command(:chocolatey), "list", "-lo", "-source", "webpi"]) do |process|
          process.each_line do |line|
            line.chomp!
            # After hitting the first dashed line, in the list of installed
            # products
            if line =~ /^-----/; in_list = true; next; end

            if !in_list or line.empty?; next; end

            # Current Chocolatey releases don't support -lo, so make sure not
            # to read uninstalled products. This is to catch
            # `--Available Products`, but just checking the dashes in case it
            # might be localised
            if line =~ /^--/; return nil; end

            values = line.split(' ', 2)
            return { :name => values[0], :ensure => values[1], :provider => self.class.name } if values[0] == @resource[:name]
          end
        end
      rescue Puppet::ExecutionFailure
        return nil
      end
    end

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
	
	args = "version", @resource[:name][/\A\S*/]
	
    if @resource[:source]
      args << "-source" << @resource[:source]
    end

	args << '| findstr /R "latest" | findstr /V "latestCompare"'
	
	[command(:chocolatey), *args]
  end

  def latest
    package_ver = ''

    begin
      output = execpipe(latestcmd()) do |process|

        process.each_line do |line|
          line.chomp!
          if line.empty?; next; end
          # Example: ( latest        : 2013.08.19.155043 )
          values = line.split(':').collect(&:strip).delete_if(&:empty?)
          package_ver = values[1]
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end
    package_ver
  end

end
