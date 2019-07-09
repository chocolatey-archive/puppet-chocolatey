require 'spec_helper_acceptance'

package_exe_path = %(C:\\'Program Files\\VideoLAN\\VLC\\vlc.exe')
software_uninstall_command = %(cmd.exe /C "C:\\Program Files\\VideoLAN\\VLC\\uninstall.exe" /S)
package_name = 'vlc'

describe 'package resource' do
  let(:pp_chocolatey_package) do
    <<-MANIFEST
      package { "#{package_name}":
        ensure   => present,
        provider => chocolatey,
        source   => 'https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/choco-pipeline-tests/'
      }
    MANIFEST
  end

  let(:pp_chocolatey_package_removed) do
    <<-MANIFEST
      package { "#{package_name}":
        ensure   => absent,
        provider => chocolatey,
      }
    MANIFEST
  end

  before(:all) do
    result = run_shell("powershell.exe -EncodedCommand #{encode_command("Test-Path #{package_exe_path}")}")
    run_shell("powershell.exe -EncodedCommand #{encode_command(software_uninstall_command.to_s)}") if result.stdout =~ %r{True}
  end

  after(:all) do
    result = run_shell("powershell.exe -EncodedCommand #{encode_command("Test-Path #{package_exe_path}")}")
    run_shell("powershell.exe -EncodedCommand #{encode_command(software_uninstall_command.to_s)}") if result.stdout =~ %r{True}
  end

  context 'install package' do
    it 'checks package is not installed' do
      run_shell("powershell.exe -EncodedCommand #{encode_command("Test-Path #{package_exe_path}")}") do |result|
        expect(result.stdout).to match(%r{False})
      end
    end

    it 'installs package' do
      apply_manifest(pp_chocolatey_package) do |result|
        expect(result.stdout).to match(%r{Notice\: \/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: created})
      end
      apply_manifest(pp_chocolatey_package, catch_changes: true)
    end
  end

  context 'remove package' do
    it 'checks package is installed' do
      run_shell("powershell.exe -EncodedCommand #{encode_command("Test-Path #{package_exe_path}")}") do |result|
        expect(result.stdout).to match(%r{True})
      end
    end

    it 'uninstalls package' do
      apply_manifest(pp_chocolatey_package_removed) do |result|
        expect(result.stdout).to match(%r{Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: removed})
      end
      apply_manifest(pp_chocolatey_package_removed, catch_changes: true)
    end
  end
end
