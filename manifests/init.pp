# chocolatey - Used for managing installation and configuration
# of Chocolatey itself.
#
# @author Rob Reynolds, Rich Siegel, and puppet-chocolatey contributors
#
# @example Default - This will by default ensure Chocolatey is installed and ready for use.
#   include chocolatey
#
# @example Override default install location
#   class {'chocolatey':
#     choco_install_location => 'D:\secured\choco',
#   }
#
# @example Use an internal Chocolatey.nupkg for installation
#   class {'chocolatey':
#     chocolatey_download_url         => 'https://internalurl/to/chocolatey.nupkg',
#     use_7zip                        => false,
#     choco_install_timeout_seconds   => 2700,
#   }
#
# @example Use a file chocolatey.0.9.9.9.nupkg for installation
#   class {'chocolatey':
#     chocolatey_download_url         => 'file:///c:/location/of/chocolatey.0.9.9.9.nupkg',
#     use_7zip                        => false,
#     choco_install_timeout_seconds   => 2700,
#   }
#
# @example Log chocolatey bootstrap installer script output
#   class {'chocolatey':
#     log_output              => true,
#   }
#
# @example Disable autouninstaller (use when less than 0.9.9.8)
#   class {'chocolatey':
#     enable_autouninstaller => false,
#   }
#
# @param [String] choco_install_location Where Chocolatey install should be
#   located. This needs to be an absolute path starting with a drive letter
#   e.g. `c:\`. Defaults to the currently detected install location based on
#   the `ChocolateyInstall` environment variable, falls back to
#   `'C:\ProgramData\chocolatey'`.
# @param [Boolean] use_7zip Whether to use built-in shell or allow installer
#   to download 7zip to extract `chocolatey.nupkg` during installation.
#   Defaults to `true`.
# @param [Integer] choco_install_timeout_seconds How long in seconds should
#   be allowed for the install of Chocolatey (including .NET Framework 4 if
#   necessary). Defaults to `1500` (25 minutes).
# @param [String] chocolatey_download_url A url that will return
#   `chocolatey.nupkg`. This must be a url, but not necessarily an OData feed.
#   Any old url location will work. Defaults to
#   `'https://chocolatey.org/api/v2/package/chocolatey/'`.
# @param [Boolean] enable_autouninstaller Should auto uninstaller be turned on?
#   Auto uninstaller is what allows Chocolatey to automatically manage the
#   uninstall of software from Programs and Features without necessarily
#   requiring a `chocolateyUninstall.ps1` file in the package. Defaults to
#   `true`.
# @param [Boolean] log_output Log output from the installer. Defaults to
#   `false`.
class chocolatey (
  $choco_install_location         = $::chocolatey::params::install_location,
  $use_7zip                       = $::chocolatey::params::use_7zip,
  $choco_install_timeout_seconds  = $::chocolatey::params::install_timeout_seconds,
  $chocolatey_download_url        = $::chocolatey::params::download_url,
  $enable_autouninstaller         = $::chocolatey::params::enable_autouninstaller,
  $log_output                     = false,
  $proxy_server                   = undef,
  $proxy_port                     = undef,
  $proxy_username                 = undef,
  $proxy_password                 = undef
) inherits ::chocolatey::params {

  validate_string($chocolatey_download_url)
  validate_re($chocolatey_download_url,['^http\:\/\/','^https\:\/\/','file\:\/\/\/'],
    "For chocolatey_download_url, if not using the default '${::chocolatey::params::download_url}', please use a Http/Https/File Url that downloads 'chocolatey.nupkg'."
  )
  validate_bool($use_7zip)
  validate_string($choco_install_location)
  validate_re($choco_install_location, '^\w\:',
    "Please use a full path for choco_install_location starting with a local drive. Reference choco_install_location => '${choco_install_location}'."
  )
  validate_integer($choco_install_timeout_seconds)
  validate_bool($enable_autouninstaller)
  validate_string($proxy_server)
  validate_string($proxy_username)
  validate_string($proxy_password)

  if $proxy_port {
    validate_integer($proxy_port)
  }
  
  if $proxy_server or $proxy_port {
    if ( ! $proxy_server) or ( ! $proxy_port) {
      fail('Both proxy_port and proxy_server must be defined!')
    }
  }

  if $proxy_username or $proxy_password {
    if ( ! $proxy_password) or ( ! $proxy_username) or ( ! $proxy_server) {
      fail('If proxy username or password is specified, all proxy settings must be defined!')
    }
  }

  if ((versioncmp($::clientversion, '3.4.0') >= 0) and (!defined('$::serverversion') or versioncmp($::serverversion, '3.4.0') >= 0)) {
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
