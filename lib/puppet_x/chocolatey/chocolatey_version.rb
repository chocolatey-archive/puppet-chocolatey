require 'pathname'
require Pathname.new(__FILE__).dirname + 'chocolatey_install'

module PuppetX
  module Chocolatey
    class ChocolateyVersion

      UPGRADE_WARNING = "!!ATTENTION!!
The next version of Chocolatey (v0.9.9) will require -y to perform
  behaviors that change state without prompting for confirmation. Start
  using it now in your automated scripts.

  For details on the all new Chocolatey, visit http://bit.ly/new_choco
"
      OLD_CHOCO_MESSAGE = "Please run chocolatey /? or chocolatey help - chocolatey v"

      def self.version
        version = nil
        choco_path = "#{PuppetX::Chocolatey::ChocolateyInstall.install_path}\\bin\\choco.exe"
        if Puppet::Util::Platform.windows? && File.exist?(choco_path)
          begin
            # call `choco -v`
            # - new choco will output a single value e.g. `0.9.9`
            # - old choco is going to return the default output e.g. `Please run chocolatey /?`
            version = Puppet::Util::Execution.execute("#{choco_path} -v").gsub(UPGRADE_WARNING,'').gsub(OLD_CHOCO_MESSAGE,'').strip
          rescue StandardError => e
            version = '0'
          end
        end

        version
      end
    end
  end
end
