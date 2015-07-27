Facter.add('choco_installpath') do
  confine :kernel => 'windows'

  setcode do
    require 'win32/registry'

    value = 'C:/ProgramData/Chocolatey'
    Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\CurrentControlSet\Control\Session Manager\Environment') do |reg|
      value = reg['ChocolateyInstall'] if reg.has_key? 'ChocolateyInstall'
    end
    value
  end
end
