require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:chocolatey, :parent => Puppet::Provider::Package) do
  desc "Package management using Chocolatey on Windows"
  confine     :operatingsystem => :windows
  has_feature :installable
  has_feature :uninstallable
  has_feature :upgradeable
  has_feature :versionable
  has_feature :install_options
  has_feature :uninstall_options
  #has_feature :holdable

  def initialize(value={})
    super(value)
    @compiled_choco = nil
  end

  def self.chocolatey_command
    if Puppet::Util::Platform.windows?
      # must determine how to get to params in ruby
      #default_location = $chocolatey::params::install_location || ENV['ALLUSERSPROFILE'] + '\chocolatey'
      chocopath = ENV['ChocolateyInstall'] ||
          ('C:\Chocolatey' if File.directory?('C:\Chocolatey')) ||
          ('C:\ProgramData\chocolatey' if File.directory?('C:\ProgramData\chocolatey')) ||
          "#{ENV['ALLUSERSPROFILE']}\chocolatey"

      chocopath += '\bin\choco.exe'
    else
      chocopath = 'choco.exe'
    end

    chocopath
  end

  def self.compiled_choco=(value)
    @compiled_choco = value
  end

  # this ultimately determines if we are on the C# version of choco
  # so commands can be adjusted accordingly
  def self.choco_exe?
    # call `choco -v` one time here and cache the result
    # - new choco will output a single value e.g. `0.9.9`
    # - old choco is going to return the default output e.g. `Please run chocolatey /?`
    if @compiled_choco.nil?
      execpipe(choco_ver_cmd) do |process|
        process.each_line do |line|
          line.chomp!
          if line.empty?; next; end
          if line.match(/Please run chocolatey.*/)
            @compiled_choco = false
          else
            @compiled_choco = true
          end
        end
      end
    end

    @compiled_choco
  end

  def self.choco_ver_cmd
    args = []
    args << '-v'

    [command(:chocolatey), *args]
  end

  def choco_exe?
    self.class.choco_exe?
  end

  commands :chocolatey => chocolatey_command

  def print()
    notice("The value is: '${name}'")
  end

  def install
    Puppet.warning('The rismoney/chocolatey module has been replaced with chocolatey/chocolatey. Please use that instead.')
    should = @resource.should(:ensure)
    case should
    when true, false, Symbol
      args = 'install', @resource[:name][/\A\S*/]
    else
      # Add the package version
      args = 'install', @resource[:name][/\A\S*/], '-version', @resource[:ensure]
    end

    if choco_exe?
      args << '-dvy'
    end

    args << @resource[:install_options]

    if @resource[:source]
      args << '-source' << @resource[:source]
    end

    chocolatey(*args)
  end

  def uninstall
    Puppet.warning('The rismoney/chocolatey module has been replaced with chocolatey/chocolatey. Please use that instead.')
    args = 'uninstall', @resource[:name][/\A\S*/]

    if choco_exe?
      args << '-dvfy'
    end

    args << @resource[:uninstall_options]

    unless choco_exe?
      if @resource[:source]
        args << '-source' << @resource[:source]
      end
    end

    chocolatey(*args)
  end

  def update
    Puppet.warning('The rismoney/chocolatey module has been replaced with chocolatey/chocolatey. Please use that instead.')
    if choco_exe?
      args = 'upgrade', @resource[:name][/\A\S*/], '-dvy'
    else
      args = 'update', @resource[:name][/\A\S*/]
    end

    args << @resource[:install_options]

    if @resource[:source]
      args << '-source' << @resource[:source]
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
    self.class.instances.each do |package|
      return package.properties if @resource[:name][/\A\S*/].downcase == package.name.downcase
    end

    return nil
  end

  def self.listcmd
    args = []
    args << 'list'
    args << '-lo'
    if choco_exe?
      args << '-r'
    end

    [command(:chocolatey), *args]
  end

  def self.instances
    packages = []

    begin
      execpipe(listcmd) do |process|
        process.each_line do |line|
          line.chomp!
          if line.empty? or line.match(/Reading environment variables.*/); next; end
          if choco_exe?
            values = line.split('|')
          else
            values = line.split(' ')
          end
          packages << new({ :name => values[0].downcase, :ensure => values[1], :provider => self.name })
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end

    packages
  end

  def latestcmd
    if choco_exe?
      args = 'upgrade', '--noop', @resource[:name][/\A\S*/], '-r'
    else
      args = 'version', @resource[:name][/\A\S*/]
    end

    if @resource[:source]
      args << '-source' << @resource[:source]
    end

    unless choco_exe?
      args << '| findstr /R "latest" | findstr /V "latestCompare"'
    end

    [command(:chocolatey), *args]
  end

  def latest
    package_ver = ''

    begin
      execpipe(latestcmd) do |process|
        process.each_line do |line|
          line.chomp!
          if line.empty?; next; end
          if choco_exe?
            values = line.split('|')
            package_ver = values[2]
          else
            # Example: ( latest        : 2013.08.19.155043 )
            values = line.split(':').collect(&:strip).delete_if(&:empty?)
            package_ver = values[1]
          end
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end

    package_ver
  end

end
