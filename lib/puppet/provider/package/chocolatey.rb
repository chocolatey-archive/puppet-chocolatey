require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:chocolatey, :parent => Puppet::Provider::Package) do
  desc "Package management using Chocolatey on Windows"

    confine    :operatingsystem => :windows

  has_feature :versionable

  commands :chocolatey => "C:/Chocolatey/chocolateyInstall/chocolatey.cmd"
 
 def print() 
   notice("The value is: '${name}'")
 end

  def install
    args = "install ", @resource[:name]
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

  
    def self.listcmd
    [command(:chocolatey), " version all -lo"]
  end

  
  def self.instances
    packages = []
    
    begin
      execpipe(listcmd()) do |process|
        
        regex = %r{^([^=]+)==([^=]+)$}
        fields = [:name, :ensure]
        hash = {}
       
        process.each_line { |line|
          if match = regex.match(line)
            fields.zip(match.captures) { |field,value|
              hash[field] = value
          }
            name = hash[:name]
            hash[:provider] = self.name
            packages << new(hash)
            hash = {}
          else
            warning("Failed to match line %s" % line)
          end
        }
      end
    rescue Puppet::ExecutionFailure
      return nil
    end
    packages
  end

  
  
  
  
end
