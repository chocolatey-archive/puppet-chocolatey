class chocolatey (
  $choco_install_location         = $::chocolatey::params::install_location,
  $use_7zip                       = $::chocolatey::params::use_7zip,
  $choco_install_timeout_seconds  = $::chocolatey::params::install_timeout_seconds,
  $chocolatey_download_url        = $::chocolatey::params::download_url,
  $enable_autouninstaller         = $::chocolatey::params::enable_autouninstaller
) inherits ::chocolatey::params {

  validate_re($chocolatey_download_url,['^http\:\/\/','^https\:\/\/'],
    "For chocolatey_download_url, if not using the default '${::chocolatey::params::download_url}', please use a Http/Https Url that downloads 'chocolatey.nupkg'."
  )
  validate_bool($use_7zip)
  validate_string($choco_install_location)
  validate_re($choco_install_location, '^\w\:',
    "Please use a full path for choco_install_location starting with a local drive. Reference choco_install_location => '${choco_install_location}'."
  )
  validate_integer($choco_install_timeout_seconds)
  validate_bool($enable_autouninstaller)

  if (versioncmp($::serverversion, '3.4.0') >= 0) or (versioncmp($::clientversion, '3.4.0') >= 0) {
    class { '::chocolatey::install': } ->
    class { '::chocolatey::config': }

    contain '::chocolatey::install'
    contain '::chocolatey::config'
  } else {
    anchor {'before_chocolatey':} ->
    class { '::chocolatey::install': } ->
    class { '::chocolatey::config': } ->
    anchor {'after_chocolatey':}
  }
}
