require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:chocolatey, :parent => Puppet::Provider::Package) do
  desc "Package management using Chocolatey on Windows"

    confine    :operatingsystem => :windows

  has_feature :versionable

  commands :chocolatey => "C:/Chocolatey/chocolateyInstall/chocolatey.cmd"
 
  def install
    args = "install ", @resource[:name]
    notice "Hello #{args})"
    chocolatey(*args)
    
  end



  def update
    self.install
  end

  
    def self.parse(line)
    #parse everything with foo==ver - stolen from pip :)
    
    if line.chomp =~ /^([^=]+)==([^=]+)$/
      {:ensure => $2, :name => $1, :provider => name}
      
    else
      nil
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
    self.class.instances.each do |provider_chocolatey|
      return provider_chocolatey.properties if @resource[:name] == provider_chocolatey.name
    end
    return nil
  end

  
  def self.instances
    packages = []
    
    # the following:
    # chocolatey version all -lo | ForEach-Object { "{0}=={1}" -f $_.Name, $_.Found }
    # returns
    #(name==version)
    
    subcommand = "version"
    package = "all"
    args=subcommand + ' ' + package + ' -lo '
    
    
    #args = subcommand + ' ' + package + ' -lo'
    chocolatey(*args) do |process|
      
      process.collect do |line|
        
        next unless options = parse(line)
      
        packages << new(options)
      end
    end
    packages
  end

  
 end
