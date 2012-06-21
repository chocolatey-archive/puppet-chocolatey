require 'puppet/provider/package'

Puppet::Type.type(:package).provide :chocolatey, :parent => Puppet::Provider::Package do
  desc "Package management via chocolatey."

  commands :chocolatey => "C:/Chocolatey/chocolateyInstall/chocolatey.cmd"
  confine    :operatingsystem => :windows
  
 
  def self.instances
    # TODO:  This is very hard 
    # self.instances is a class method of the provider that returns all of 
	# the resources present on the system. Not just a specific resource. 
	# If you are working with a new package manager, then self.instances 
	# will return a array of hashes. Each element in the array describing a single package. 
	
  end

  
  # source and name are required
  def install
    args = "install", @resource[:name]
    chocolatey(*args)
  end

  def query
  
		# Puppet will call the query method on the instance of the package 
		# provider resource when checking if the package is installed already or 
		# not. It's a determination for one specific package, the package modeled by 
		# the resource the method is called on. 

		# Query provides the information for the single package identified by @Resource[:name]. 

   
    chocolatey version @resource[:name]
    {:ensure => :present}
  rescue
    {:ensure => :absent}
  end

  def uninstall
    args = "uninstall" + @resource[:name]
    chocolatey(*args)
  end


end
  
  
  
  





