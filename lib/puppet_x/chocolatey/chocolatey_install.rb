if ENV['ProgramData'] != nil
  program_data = ENV['ProgramData']
else
  program_data = 'c:\ProgramData'
end

module PuppetX
  module Chocolatey
    class ChocolateyInstall

      def self.install_path
        if Puppet::Util::Platform.windows?
        require 'win32/registry'

        value = nil
        begin
          hive = Win32::Registry::HKEY_LOCAL_MACHINE
          hive.open('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', Win32::Registry::KEY_READ | 0x100) do |reg|
            value = reg['ChocolateyInstall']
          end
        rescue Win32::Registry::Error => e
          value = nil
        end
      end

      value || program_data + '\chocolatey'
      end

    end
  end
end
