class chocolatey (
  $chocolatey_download_url = $::chocolatey::params::download_url,
  $use_7zip                = $::chocolatey::params::use_7zip,
  $choco_install_location  = $::chocolatey::params::install_location,
  $choco_install_timeout   = $::chocolatey::params::install_timeout
){
  class { '::chocolatey::install': }
}
