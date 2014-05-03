class chocolatey (
  $source        = 'http://chocolatey.org/api/v2/package/chocolatey/',
  $unzip         = '7za',
  $download_path = 'c:\\Windows\\Temp\\') {
  validate_re($unzip, '^(7za|windows)$')

  file { 'chocolatey script':
    path    => "${download_path}\\InstallChocolatey.ps1",
    content => template('chocolatey/InstallChocolatey.ps1'),
  }

  exec { 'install chocolatey':
    command   => "& '${download_path}\\InstallChocolatey.ps1' %*",
    provider  => powershell,
    subscribe => File['chocolatey script'],
    creates   => 'c:\\Chocolatey\\',
  }
}
