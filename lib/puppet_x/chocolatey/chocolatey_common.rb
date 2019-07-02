require 'pathname'
require Pathname.new(__FILE__).dirname + 'chocolatey_version'
require Pathname.new(__FILE__).dirname + 'chocolatey_install'

# Module used for general Chocolatey commands and constants
module PuppetX::Chocolatey::ChocolateyCommon
  # First C# version of Chocolatey
  FIRST_COMPILED_CHOCO_VERSION = '0.9.9.0'.freeze unless defined? FIRST_COMPILED_CHOCO_VERSION
  # Specifes the minimum version that allows the `ignore-package-exit-codes` flag
  MINIMUM_SUPPORTED_CHOCO_VERSION_EXIT_CODES = '0.9.10.0'.freeze unless defined? MINIMUM_SUPPORTED_CHOCO_VERSION_EXIT_CODES
  # Specifies the minimum version that allows uninstalling with a source argument
  MINIMUM_SUPPORTED_CHOCO_UNINSTALL_SOURCE = '0.9.10.0'.freeze unless defined? MINIMUM_SUPPORTED_CHOCO_UNINSTALL_SOURCE
  # Specifies the minimum version that allows the '--no-progress' flag
  MINIMUM_SUPPORTED_CHOCO_VERSION_NO_PROGRESS = '0.10.4.0'.freeze unless defined? MINIMUM_SUPPORTED_CHOCO_VERSION_NO_PROGRESS

  def file_exists?(path)
    File.exist?(path)
  end
  module_function :file_exists?

  # Retrieves path of Chocolatey executable.
  #
  # @return [String] Path to Chocolatey executable
  def chocolatey_command
    if Puppet::Util::Platform.windows?
      # When attempting to find the choco command executable, the following
      # paths are checked:
      # - Start with the install_path. If choco is found with environment
      #   variables through the registry or a check on the
      #   ChocolateyInstall env var (first install of Choco may only have
      #   this), then use that path.
      # - Next look to the most commonly used install location (ProgramData)
      # - Fall back to the older install location for older installations
      # - If all else fails, attempt to find Chocolatey in the default place
      #   it installs
      choco_install_path = PuppetX::Chocolatey::ChocolateyInstall.install_path

      chocopath =  (choco_install_path if choco_install_path && file_exists?("#{choco_install_path}\\choco.exe")) ||
                   ('C:\ProgramData\chocolatey' if file_exists?('C:\ProgramData\chocolatey\choco.exe')) ||
                   ('C:\Chocolatey' if file_exists?('C:\Chocolatey\choco.exe')) ||
                   "#{ENV['ALLUSERSPROFILE']}\\chocolatey"

      chocopath += '\choco.exe'
    else
      chocopath = 'choco.exe'
    end

    chocopath
  end
  module_function :chocolatey_command

  # Sets the `ChocolateyInstall` environment variables to the current Chocolatey install path
  def set_env_chocolateyinstall
    ENV['ChocolateyInstall'] = PuppetX::Chocolatey::ChocolateyInstall.install_path
  end
  module_function :set_env_chocolateyinstall

  # Retrieves version of currently installed Chocolatey package.
  #
  # @return [String] Semver string of Chocolatey version
  def choco_version
    @chocoversion ||= strip_beta_from_version(PuppetX::Chocolatey::ChocolateyVersion.version)
  end
  module_function :choco_version

  # Removes the beta section of the version string.
  #
  # @param [String] value Semver string
  # @return [String] Semver string with beta postfix removed
  def self.strip_beta_from_version(value)
    return nil if value.nil?

    value.split(%r{-})[0]
  end

  # Retrieves the path of the Chocolatey configuration file.
  #
  # @return [String] Path to config file
  def choco_config_file
    choco_install_path = PuppetX::Chocolatey::ChocolateyInstall.install_path
    choco_config = "#{choco_install_path}\\config\\chocolatey.config"

    # choco may be installed, but a config file doesn't exist until the
    # first run of choco - trigger that by checking the version
    return choco_config if file_exists?(choco_config)

    old_choco_config = "#{choco_install_path}\\chocolateyinstall\\chocolatey.config"

    return old_choco_config if file_exists?(old_choco_config)

    nil
  end
  module_function :choco_config_file

  # Clears global common constants.
  def clear_cached_values
    @chocoversion = nil
    @compiled_choco = nil
  end
  module_function :clear_cached_values
end
