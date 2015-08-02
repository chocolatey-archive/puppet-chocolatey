# == Class chocolatey::params
#
# This class is meant to be called from chocolatey.
class chocolatey::params {
  $install_location = 'C:\ProgramData\chocolatey'
  $download_url     = 'https://chocolatey.org/api/v2/package/chocolatey/'
  $use_7zip         = false
  $install_timeout  = 1500
}
