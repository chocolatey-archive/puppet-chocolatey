# chocolatey::config - Private class used for configuration
class chocolatey::config {
  assert_private()

  # this will require a second converge when choco is not
  # installed the first time through. This is on purpose
  # as we don't want to try to set these values for a
  # version less than 0.9.9 and we don't know what the
  # user may link to - it could be an older version of
  # Chocolatey

  $_choco_exe_path = "${chocolatey::choco_install_location}\\bin\\choco.exe"

  if versioncmp($::chocolateyversion, '0.9.9.0') >= 0 {

    $_enable_autouninstaller = $chocolatey::enable_autouninstaller ? {
      false => 'disable',
      default => 'enable'
    }

# lint:ignore:80chars
    exec { "chocolatey_autouninstaller_${_enable_autouninstaller}":
      path        => $::path,
      command     => "${_choco_exe_path} feature -r ${_enable_autouninstaller} -n autoUninstaller",
      unless      => "cmd.exe /c ${_choco_exe_path} feature list -r | findstr /B /I /C:\"autoUninstaller - [${_enable_autouninstaller}d]\"",
      environment => ["ChocolateyInstall=${::chocolatey::choco_install_location}"]
    }
# lint:endignore
  }

# lint:ignore:80chars
  if $source_url != undef {
    $source_cmd = "${_choco_exe_path} source add -n=${source_name} -s ${source_url}"

    # Check if there is a user/password set, add params to source url
    if $source_user != undef and $source_password != undef {
      $_source_cmd = "${source_cmd} -u=${source_user} -p=${source_password}"
    }else{
      notify { "source user and password not set, using unauthenticated source": }
      $_source_cmd = $source_cmd
    }

    # Check if priority is set, default to 0
    if $source_priority == undef{
      notify { "Chocolatey source priority not set, defaulting to 0": }
      $source_priority = '0'
    }

    exec { 'add_source':
      path        => $::path,
      command     => "${_source_cmd} --priority=${source_priority}",
      environment => ["ChocolateyInstall=${::chocolatey::choco_install_location}"]
    }
  }
# lint:endignore
}
