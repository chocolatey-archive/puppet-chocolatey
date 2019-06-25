# rubocop:disable Style/ClassAndModuleChildren

# Puppet Extensions Module
module PuppetX
  # Chocolatey module
  module Chocolatey
    # Class for installation of Chocolatey
    class ChocolateyInstall
      # Retrieves the path to the folder containing the Chocolatey instllation
      def self.install_path
        value = nil

        if Puppet::Util::Platform.windows?
          require 'win32/registry'

          begin
            hive = Win32::Registry::HKEY_LOCAL_MACHINE
            hive.open('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', Win32::Registry::KEY_READ | 0x100) do |reg|
              value = reg['ChocolateyInstall']
            end
          rescue Win32::Registry::Error
            value = nil
          end
        end

        # If machine level is not set, use process or user as the intended
        # location where Chocolatey would be installed.
        # Since it is technically possible that Chocolatey could exist on
        # non-Windows installations, we don't want to confine this
        # to just Windows.
        if value.nil?
          value = ENV['ChocolateyInstall']
        end

        value
      end

      # Retrieves the path to the temporary folder on the system
      #
      # @return [String] Path to temp folder
      def self.temp_dir
        return unless Puppet::Util::Platform.windows?
        require 'win32/registry'

        value = nil
        begin
          # looking at current user may likely fail because it's likely going to be LocalSystem
          hive = Win32::Registry::HKEY_CURRENT_USER
          hive.open('Environment', Win32::Registry::KEY_READ | 0x100) do |reg|
            value = reg['TEMP']
          end
        rescue Win32::Registry::Error
          value = nil
        end

        if value.nil?
          begin
            hive = Win32::Registry::HKEY_LOCAL_MACHINE
            hive.open('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', Win32::Registry::KEY_READ | 0x100) do |reg|
              value = reg['TEMP']
            end
          rescue Win32::Registry::Error
            value = nil
          end
        end

        value
      end
    end
  end
end
