# @summary Sets up default parameters
#
# @api private
class chocolatey::params {
  $install_location         = $facts['choco_install_path'] # default is C:\ProgramData\chocolatey
  $download_url             = 'https://chocolatey.org/api/v2/package/chocolatey/'
  $use_7zip                 = false
  $seven_zip_download_url   = 'https://chocolatey.org/7za.exe'
  $install_timeout_seconds  = 1500
  $enable_autouninstaller   = true
  $chocolatey_version       = $facts['chocolateyversion']
}
