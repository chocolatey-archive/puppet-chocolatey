# == Class chocolatey::install
#
# This class is called from chocolatey for install.
class chocolatey::install (
  $chocolatey_download_url = $chocolatey::params::download_url,
  $use_7zip                = $chocolatey::params::use_7zip,
  $choco_install_location  = $chocolatey::params::install_location,
  $choco_install_timeout   = $chocolatey::params::install_timeout
){
  #todo:
  # - restrict based on osfamily?

  $download_url = $chocolatey_download_url
  $unzip_type   = $use_7zip ? {
    true      => '7zip',
    default   => 'windows'
  }

  # These are specifically necessary to ensure that we know the path
  # has been updated in the current run. They are typically a noop.

  windows_env { 'chocolatey_ChocolateyInstall_env':
    ensure    => present,
    variable  => 'ChocolateyInstall',
    mergemode => 'clobber',
    value     => $choco_install_location,
    notify    => Exec['install_chocolatey_official'],
  }

  windows_env { 'chocolatey_PATH_env':
    ensure    => present,
    variable  => 'PATH',
    mergemode => 'prepend',
    value     => "${choco_install_location}\\bin",
    notify    => Exec['install_chocolatey_official'],
  }

  exec { 'install_chocolatey_official':
    command  => template('chocolatey/InstallChocolatey.ps1.erb'),
    creates  => "${choco_install_location}\\bin\\choco.exe",
    provider => powershell,
    timeout  => $choco_install_timeout,
  }
}
