# chocolatey::install - Private class used for install of Chocolatey
class chocolatey::install {
  assert_private()

  $install_proxy = $::chocolatey::install_proxy
  $_install_proxy = $install_proxy ? {
    undef   => '$false',
    default => "'${install_proxy}'",
  }
  $download_url            = $::chocolatey::chocolatey_download_url
  $seven_zip_download_url  = $::chocolatey::seven_zip_download_url
  $seven_zip_exe           = "${facts['choco_temp_dir']}\\7za.exe"

  if $::chocolatey::use_7zip {
    $unzip_type = '7zip'
    file { $seven_zip_exe:
      ensure  => present,
      source  => $seven_zip_download_url,
      replace => false,
      mode    => '0755',
      before  => Exec['install_chocolatey_official'],
    }
  } else {
    $unzip_type = 'windows'
  }

  registry_value { 'ChocolateyInstall environment value':
    ensure => present,
    path   => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\ChocolateyInstall',
    type   => 'string',
    data   => $chocolatey::choco_install_location,
  }

  exec { 'install_chocolatey_official':
    command     => template('chocolatey/InstallChocolatey.ps1.erb'),
    creates     => "${::chocolatey::choco_install_location}\\bin\\choco.exe",
    provider    => powershell,
    timeout     => $::chocolatey::choco_install_timeout_seconds,
    logoutput   => $::chocolatey::log_output,
    environment => ["ChocolateyInstall=${::chocolatey::choco_install_location}"],
    require     => Registry_value['ChocolateyInstall environment value'],
  }
}
