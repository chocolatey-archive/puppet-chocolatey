class chocolatey ($source = 'http://chocolatey.org/api/v2/package/chocolatey/', $unzip = '7za') {
  file { 'chocolatey script':
    path    => 'c:\\Windows\\Temp\\InstallChocolatey.ps1',
    content => template('chocolatey/InstallChocolatey.ps1'),
  }

  exec { 'install chocolatey':
    command     => "-NoProfile -ExecutionPolicy unrestricted -Command \"& '%TEMP%InstallChocolatey.ps1' %*\"",
    provider    => powershell,
    subscribe   => File['chocolatey script'],
    refreshonly => true,
  }
}
