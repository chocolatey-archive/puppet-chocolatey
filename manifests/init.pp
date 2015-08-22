class chocolatey (
  $chocolatey_download_url = $::chocolatey::params::download_url,
  $use_7zip                = $::chocolatey::params::use_7zip,
  $choco_install_location  = $::chocolatey::params::install_location,
  $choco_install_timeout   = $::chocolatey::params::install_timeout,
  $enable_autouninstaller  = $::chocolatey::params::enable_autouninstaller
) inherits ::chocolatey::params {
  class { '::chocolatey::install': } ->
  class { '::chocolatey::config': }


  #todo: check version of Puppet before this construct.
  contain '::chocolatey::install'
  contain '::chocolatey::config'
}
