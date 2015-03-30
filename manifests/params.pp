# == Class chocolatey::params
#
# This class is meant to be called from chocolatey.
# It sets variables according to platform.
#
class chocolatey::params {
  $install_location = ENV['ALLUSERSPROFILE'] + '\chocolatey'
}
