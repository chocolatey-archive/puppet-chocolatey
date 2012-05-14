require 'puppet/provider/package'

Puppet::Type.type(:package).provide :chocolatey, :parent => Puppet::Provider::Package do
  desc "Package management via chocolatey."

  commands :chocolatey => "C:/Chocolatey/chocolateyInstall/chocolatey.cmd"
  confine    :operatingsystem => :windows
  
 
  def self.instances
    # TODO:  This is very hard 
    
  end

  
  # source and name are required
  def install
    args = "install", @resource[:name]
    chocolatey(*args)
  end

  def query
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
  
  
  
  





