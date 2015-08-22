# chocolatey::source - Manage sources for Chocolatey
#
# @author Rob Reynolds, Rich Siegel, and puppet-chocolatey contributors
#
# @example Add a source
#   chocolatey::source {'dude':
#     ensure    => 'present',
#     location  => 'https://internal/ODatafeed',
#   }
#
# @example Disable default source
#   chocolatey::source {'chocolatey':
#     enable => false,
#   }
#
# @param [String] ensure Whether the source should exist or not. Defaults to
#   'present'. Valid values are `present`, `absent`.
# @param [String] source_name The name of the source. Defaults to the name
#   (`$title`) of of the resource.
# @param [String] location The location of the source. Can be a url pointing to
#   and OData feed (like chocolatey/chocolatey_server), a CIFS (UNC) share,
#   or a local folder. Defaults to the name (`$title`) of of the resource.
# @param [Boolean] enable Whether to use built-in shell or allow installer
#   to download 7zip to extract `chocolatey.nupkg` during installation.
#   Defaults to `true`.
# @param [String] user_name Optional user name for authenticated feeds. Defaults
#   to `undef`.
# @param [String] password Optional password for authenticated feeds. Defaults
#   to `undef`.
define chocolatey::source (
  $ensure      = 'present',
  $source_name = $title,
  $location    = $title,
  $enable      = true,
  $user_name   = undef,
  $password    = undef
) {

  require chocolatey

  #todo: do we fail if the version is wrong?
  if (versioncmp($::chocolateyversion, '0.9.9.0') >= 0) or ($::chocolateyversion == '0') {
    $_choco_exe_path = "${::choco_install_path}\\bin\\choco.exe"
    $_source_default_args = "-r -n ${source_name}"
    $_location_args = "-s ${location}"

    $_user_args = $user_name ? {
      undef   => '',
      default => "-u ${user_name}",
    }

    $_pass_args = $password ? {
      undef   => '',
      default => "-p ${password}",
    }

    if ($ensure == 'absent') {
      $_source_action = 'remove'
      exec { "chocolatey_source_${source_name}_${_source_action}":
        path    => $::path,
        command => "${_choco_exe_path} source ${_source_action} ${_source_default_args}",
        onlyif  => "cmd.exe /c ${_choco_exe_path} source list -r | findstr /B /I \"${source_name}\"",
        require => Exec['install_chocolatey_official'],
      }
    } else {
      if ($enable){
        # Since we encrypt user/pass, it won't update the source if that is all that changes.
        #$_source_action = 'add'
        exec { "chocolatey_source_${source_name}_${_source_action}":
          path    => $::path,
          command => "cmd.exe /c ${_choco_exe_path} source remove ${_source_default_args} && ${_choco_exe_path} source add ${_source_default_args} ${_location_args} ${_user_args} ${_pass_args}",
          unless  => "cmd.exe /c ${_choco_exe_path} source list -r | findstr /X /I \"${source_name}.* - ${location}\"",
          require => Exec['install_chocolatey_official'],
        }

        $_source_action = 'enable'
        exec { "chocolatey_source_${source_name}_enable":
          path    => $::path,
          command => "${_choco_exe_path} source ${_source_action} ${_source_default_args}",
          unless  => "cmd.exe /c ${_choco_exe_path} source list -r | findstr /B /I /C:\"${source_name} -\"",
          require => Exec['install_chocolatey_official'],
        }
      } else {
        $_source_action = 'disable'
        exec { "chocolatey_source_${source_name}_${_source_action}":
          path    => $::path,
          command => "${_choco_exe_path} source ${_source_action} ${_source_default_args}",
          unless  => "cmd.exe /c ${_choco_exe_path} source list -r | findstr /B /I /C:\"${source_name} [Disabled]\"",
          require => Exec['install_chocolatey_official'],
        }
      }
    }
  }
}
