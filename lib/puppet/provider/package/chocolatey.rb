require 'puppet/provider/package'

Puppet::Type.type(:package).provide :chocolatey, :parent => Puppet::Provider::Package do
  desc "Package management via chocolatey."

  commands :chocolatey => ENV['ChocolateyInstall'] + "/chocolateyInstall/chocolatey.cmd"
  confine    :operatingsystem => :windows
  
  def self.parse(line)
    #parse everything with foo==ver - stolen from pip :)
    if line.chomp =~ /^([^=]+)==([^=]+)$/
      {:ensure => $2, :name => $1, :provider => name}
    else
      nil
    end
  end

  # from puppet-dev mailing list:
  # self.instances is a class method of the provider that returns all of 
	# the resources present on the system. Not just a specific resource. 
	# then self.instances will return a array of hashes. Each element in the array describing a single package. 
	
  
  def self.instances
    packages = []
    
    # the following:
    # chocolatey version all -lo | % { "{0}=={1}" -f $_.Name, $_.Found }
    # returns
    #(name==version)
    
    subcommand = "version"
    package = "all"
    args = = subcommand + " " + package + " " + %q{-lo | % { "{0}=={1}" -f $_.Name, $_.Found }}    
    chocolatey(*args) do |process|
      process.collect do |line|
        next unless options = parse(line)
        packages << new(options)
      end
    end
    packages
  end

  
  # source and name are required
  def install
    args = "install", @resource[:name]
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
      return provider_chocolatey.properties if @resource[:name] == provider_chocolatey.name
    end
    return nil
  end

   
  def uninstall
    args = "uninstall" + @resource[:name]
    chocolatey(*args)
  end

def latest
    # force chocolatey version output formatting (name==latest)
    package = @resource[:name]
    subcommand = "version"
    args = subcommand + " " + package + " " + %q{| % { "{0}=={1}" -f $_.Name, $_.Latest }}    
    chocolatey(*args) do |process|
      process.collect do |line|
        next unless options = parse(line)
        packages << new(options)
      end
    end
    packages
  end
  
end