# authored by Rich Siegel (rismoney@gmail.com)
# with help from some of the other pkg providers of course

require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:chocolatey, :parent => Puppet::Provider::Package) do
  desc "Package management using Chocolatey on Windows"

    confine    :operatingsystem => :windows

  has_feature :installable, :uninstallable, :upgradeable, :versionable, :install_options
  chocopath = ENV['ChocolateyInstall'].to_s
  commands :chocolatey => chocopath + "/chocolateyInstall/chocolatey.cmd"

  def install
    should = @resource.should(:ensure)
    case should
    when true, false, Symbol
      args = "install", @resource[:name][/\A\S*/], resource[:install_options]
    else
      # Add the package version
      args = "install", @resource[:name][/\A\S*/], "-version", resource[:ensure], resource[:install_options]
    end


    chocolatey(*args)
  end

  def uninstall
    args = "uninstall", @resource[:name][/\A\S*/]
    chocolatey(*args)
  end

  def update
    args = "update", @resource[:name][/\A\S*/], resource[:install_options]
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
    [command(:chocolatey), ' version all -lo ^| % { \"{0}=={1}\" -f $_.Name, $_.Found }']
  end

  def self.instances
    packages = []

    begin
      execpipe(listcmd()) do |process|

        regex = %r{^([^=]+)==([^=]+)$}
        fields = [:name, :ensure]
        hash = {}

        process.each_line { |line|
          line.chomp!
          if match = regex.match(line)
            fields.zip(match.captures) { |field,value|
              hash[field] = value
          }
            name = hash[:name]
            version = hash[:ensure]
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

  def latestcmd
    [command(:chocolatey), ' version ' + @resource[:name][/\A\S*/] + ' ^| % { \"{0}=={1}\" -f $_.Name, $_.Latest }']
  end

  def latest
    packages = []

    begin
      output = execpipe(latestcmd()) do |process|
        puts "#{output}"
        regex = %r{^([^=]+)==([^=]+)$}
        fields = [:name, :latest]
        hash = {}

        process.each_line { |line|
          line.chomp!
          if match = regex.match(line)
            fields.zip(match.captures) { |field,value|
              hash[field] = value
          }
            latest = hash[:latest]
            hash[:provider] = latest
            hash = {}
            return latest
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
