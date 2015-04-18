require 'spec_helper_acceptance'

describe 'chocolatey provider' do
  context 'when chocolatey is installed' do
    it 'should install notepadplusplus with chocolatey' do

      install_chocolatey = <<-EOS
        exec { 'install chocolatey':
          command => 'iex ((new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1"))',
          unless  => 'if (Test-Path "C:\\Chocolatey\\bin\\chocolatey.bat") {exit 0} else {exit 1}',
          provider => powershell,
        }
      EOS

      choco_notepad_plus = <<-EOS
        package { 'notepadplusplus':
          ensure          => installed,
          provider        => 'chocolatey',
        }
      EOS

      apply_manifest(install_chocolatey, :catch_failures => true)

      apply_manifest(choco_notepad_plus, :catch_failures => true)
      apply_manifest(choco_notepad_plus, :catch_changes  => true)
    end
  end
end