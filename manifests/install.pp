# == Class chocolatey::install
#
# This class is called from chocolatey for install.
class chocolatey::install (
  $chocolatey_download_url = $chocolatey::params::download_url,
  $use_7zip                = $chocolatey::params::use_7zip,
  $choco_install_location  = $chocolatey::params::install_location,
  $choco_install_timeout   = $chocolatey::params::install_timeout
){
  # todo:
  # - allow custom installation directory to be specified
  #   - set the fact that sets the chocolateyInstall Variable in the path
  # - restrict based on osfamily?

  $download_url = $chocolatey_download_url
  $unzip_type   = $use_7zip ? {
    true      => '7zip',
    default   => 'windows'
  }

  # call for the custom fact to be set

  exec { 'install_chocolatey_official':
    command  => template('chocolatey/InstallChocolatey.ps1.erb'),
    creates  => "${choco_install_location}\\bin\\choco.exe",
    provider => powershell,
    timeout  => $choco_install_timeout,
  }

  # we'll need a trick to update path once we run

}
