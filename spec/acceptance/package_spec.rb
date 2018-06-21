require 'spec_helper_acceptance'

describe 'Chocolatey Package' do

  context 'MODULES-3037 Install a known good package via manifest and remove via manifest' do
    package_name = 'vlc'
    package_exe_path = %{C:\\'Program Files\\VideoLAN\\VLC\\vlc.exe'}
    software_uninstall_command = %{cmd.exe /C C:\\'Program Files\\VideoLAN\\VLC\\uninstall.exe' /S}

    chocolatey_package_manifest = <<-PP
      package { "#{package_name}":
        ensure   => present,
        provider => chocolatey,
        source   => 'https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/choco-pipeline-tests/'
      }
    PP

    chocolatey_package_manifest_chng = <<-PP
      package { "#{package_name}":
        ensure   => absent,
        provider => chocolatey,
      }
    PP

    after(:all) do
      windows_agents.each do | agent |
        on(agent, powershell("test-path #{package_exe_path}", {'EncodedCommand' => true}), :catch_errors => true) do | result |
          on(agent, powershell(software_uninstall_command, {'EncodedCommand' => true}), :catch_errors => true) if result.stdout =~ /True/
        end
      end
    end

    windows_agents.each do | agent |

      it 'Should verify the package is not installed.' do
        on(agent, powershell("test-path #{package_exe_path}", {'EncodedCommand' => true}), :catch_errors => true) do | result |
          assert_match(/False/i, result.output, "#{package_name} was present before application of manifest.")
        end
      end

      it 'Should apply the manifest to install the package' do
        execute_manifest_on(agent, chocolatey_package_manifest, :catch_failures => true) do | result |
          assert_match(/Notice\: \/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: created/, result.stdout, "stdout did not report package creation of #{package_name}")
        end
      end

      it "should have a valid version of #{package_name}" do
        on(agent, powershell("test-path #{package_exe_path}", {'EncodedCommand' => true}), :catch_errors => true) do |result|
          assert_match(/True/i, result.output, "#{package_name} was not present after application of manifest.")
        end
      end

      it 'Should uninstall the package' do
        execute_manifest_on(agent, chocolatey_package_manifest_chng, :catch_failures => true) do | result |
          assert_match(/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: removed/, result.stdout, "stdout did not report package removal of #{package_name}")
        end
      end
    end
  end

  skip 'UTF-8 Not Suported At This Time - MODULES-3037 Install a known good package with utf-8 via manifest and remove via manifest' do
    package_name = '竹ChocolateyGUIÖ'
    package_exe_path = %{C:\\'Program Files (x86)\\ChocolateyGUI\\ChocolateyGUI.exe'}
    software_uninstall_command = %{msiexec /x C:\\ProgramData\\chocolatey\\lib\\竹ChocolateyGUIÖ\\tools\\竹ChocolateyGUIÖ.msi /q}.force_encoding("ASCII-8BIT")

    chocolatey_package_manifest = <<-PP
      package { "#{package_name}":
        ensure  => present,
        provider => chocolatey,
        source => 'https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/choco-pipeline-tests/'
      }
    PP

    chocolatey_package_manifest_chng = <<-PP
      package { "#{package_name}":
        ensure   => absent,
        provider => chocolatey,
      }
    PP

    after(:all) do
      windows_agents.each do | agent |
        on(agent, powershell("test-path #{package_exe_path}", {'EncodedCommand' => true}), :catch_errors => true) do | result |
          on(agent, powershell(software_uninstall_command, {'EncodedCommand' => true}), :catch_errors => true) if result.stdout =~ /True/
        end
      end
    end

    windows_agents.each do | agent |

      it 'Should verify the package is not installed.' do
        on(agent, powershell("test-path #{package_exe_path}", {'EncodedCommand' => true}), :catch_errors => true) do | result |
          assert_match(/False/i, result.output, "#{package_name} was present before application of manifest.")
        end
      end

      it 'Should apply the manifest to install the package' do
        execute_manifest_on(agent, chocolatey_package_manifest, :catch_failures => true) do | result |
          assert_match(/Notice\: \/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: created/, result.stdout, "stdout did not report package creation of #{package_name}")
        end
      end

      it "should have a valid version of #{package_name}" do
        on(agent, powershell("test-path #{package_exe_path}", {'EncodedCommand' => true}), :catch_errors => true) do |result|
          assert_match(/True/i, result.output, "#{package_name} was not present after application of manifest.")
        end
      end

      it 'Should uninstall the package' do
        execute_manifest_on(agent, chocolatey_package_manifest_chng, :catch_failures => true) do | result |
          assert_match(/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: removed/, result.stdout, "stdout did not report package removal of #{package_name}")
        end
      end
    end
  end
end

