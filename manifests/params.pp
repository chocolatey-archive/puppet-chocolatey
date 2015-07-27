# == Class chocolatey::params
#
# This class is meant to be called from chocolatey.
# It sets variables according to platform.
#
# NOTE: CURRENTLY NON-FUNCTIONAL
class chocolatey::params {
  $install_location = $::choco_installpath,
}
