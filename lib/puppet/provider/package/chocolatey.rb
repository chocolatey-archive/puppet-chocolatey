require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:choc, :parent => Puppet::Provider::Package) do
  desc "Package management using Chocolatey on Windows"

    confine    :operatingsystem => :windows

  has_feature :versionable

  #replace the line below with
  #commands :brew => "/usr/local/bin/brew"
  commands :choc => "C:\Chocolatey\chocolateyInstall.cmd"
 
 # Install packages, known as formulas, using brew.
  def install
    should = @resource[:ensure]

    package_name = @resource[:name]
    case should
    when true, false, Symbol
      # pass
    else
      package_name += "-#{should}"
    end

    output = choc(:install, package_name)

    # Fail hard if there is no formula available. commented lines 29-31. need to understand choc output
    #if output =~ /Error: No available formula/
    #  raise Puppet::ExecutionFailure, "Could not find package #{@resource[:name]}"
    #end
  end

  # chocolatey doesn't support uninstalls...
  
  # def uninstall
    # choc(:uninstall, @resource[:name])
  # end

  def update
    self.install
  end

  # def query
    # self.class.package_list(:justme => resource[:name])
  # end

  # def latest
    # hash = self.class.package_list(:justme => resource[:name])
    # hash[:ensure]
  # end

  # def self.package_list(options={})
    # brew_list_command = [command(:brew), "list", "--versions"]

    # if name = options[:justme]
      # brew_list_command << name
    # end

    # begin
      # list = execute(brew_list_command).lines.map {|line| name_version_split(line) }
    # rescue Puppet::ExecutionFailure => detail
      # raise Puppet::Error, "Could not list packages: #{detail}"
    # end

    # if options[:justme]
      # return list.shift
    # else
      # return list
    # end
  # end

  # def self.name_version_split(line)
    # if line =~ (/^(\S+)\s+(.+)/)
      # name = $1
      # version = $2
      # {
        # :name     => name,
        # :ensure   => version,
        # :provider => :brew
      # }
    # else
      # Puppet.warning "Could not match #{line}"
      # nil
    # end
  # end

  # def self.instances(justme = false)
    # package_list.collect { |hash| new(hash) }
  # end
# end
