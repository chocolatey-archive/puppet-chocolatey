# @summary Used for managing installation and configuration of Chocolatey itself.
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
#
# @param [Boolean] use_7zip Whether to use built-in shell or allow installer
#   to download 7zip to extract `chocolatey.nupkg` during installation.
#   Defaults to `false`.
#
# @param [String] seven_zip_download_url Specifies the source file for 7za.exe.
#   Supports all sources supported by Puppet's file resource. You should use
#   a 32bit binary for compatibility.
#   Defaults to 'https://chocolatey.org/7za.exe'.
#
# @param [Integer] choco_install_timeout_seconds How long in seconds should
#   be allowed for the install of Chocolatey (including .NET Framework 4 if
#   necessary). Defaults to `1500` (25 minutes).
#
# @param [String] chocolatey_download_url A url that will return
#   `chocolatey.nupkg`. This must be a url, but not necessarily an OData feed.
#   Any old url location will work. Defaults to
#   `'https://chocolatey.org/api/v2/package/chocolatey/'`.
#
# @param [Boolean] enable_autouninstaller [Deprecated] - Should auto
#   uninstaller be turned on? Auto uninstaller is what allows Chocolatey to
#   automatically manage the uninstall of software from Programs and Features
#   without necessarily requiring a `chocolateyUninstall.ps1` file in the
#   package. Defaults to `true`. Setting is ignored in Chocolatey v0.9.10+.
#
# @param [Boolean] log_output Log output from the installer. Defaults to
#   `false`.
#
# @param [String] chocolatey_version - **Informational** parameter to tell
#   Chocolatey what version to expect and to pre-load features with, falls
#   back to `$::chocolateyversion`.
#
# @param install_proxy Proxy server to use to use for installation of chocolatey itself or
#   `undef` to not use a proxy
class chocolatey (
  Stdlib::Windowspath $choco_install_location = $::chocolatey::params::install_location,
  Boolean $use_7zip                           = $::chocolatey::params::use_7zip,
  String $seven_zip_download_url              = $::chocolatey::params::seven_zip_download_url,
  Integer $choco_install_timeout_seconds      = $::chocolatey::params::install_timeout_seconds,
  Stdlib::Filesource $chocolatey_download_url = $::chocolatey::params::download_url,
  Boolean $enable_autouninstaller             = $::chocolatey::params::enable_autouninstaller,
  $log_output                                 = false,
  $chocolatey_version                         = $::chocolatey::params::chocolatey_version,
  $install_proxy                              = undef,
) inherits ::chocolatey::params {

  class { '::chocolatey::install': }
  -> class { '::chocolatey::config': }

  contain '::chocolatey::install'
  contain '::chocolatey::config'
}
