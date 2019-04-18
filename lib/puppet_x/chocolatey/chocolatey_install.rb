module PuppetX
  module Chocolatey
    class ChocolateyInstall

      def self.install_path
        value = nil

        if Puppet::Util::Platform.windows?
          require 'win32/registry'

          begin
            hive = Win32::Registry::HKEY_LOCAL_MACHINE
            hive.open('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', Win32::Registry::KEY_READ | 0x100) do |reg|
              value = reg['ChocolateyInstall']
            end
          rescue Win32::Registry::Error => e
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

      def self.temp_dir
        if Puppet::Util::Platform.windows?
          require 'win32/registry'
  
          value = nil
          begin
            # looking at current user may likely fail because it's likely going to be LocalSystem
            hive = Win32::Registry::HKEY_CURRENT_USER
            hive.open('Environment', Win32::Registry::KEY_READ | 0x100) do |reg|
              value = reg['TEMP']
            end
          rescue Win32::Registry::Error => e
            value = nil
          end
  
          if value.nil?
            begin
              hive = Win32::Registry::HKEY_LOCAL_MACHINE
              hive.open('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', Win32::Registry::KEY_READ | 0x100) do |reg|
                value = reg['TEMP']
              end
            rescue Win32::Registry::Error => e
              value = nil
            end
          end

          value
        end
      end
    end
  end
end
