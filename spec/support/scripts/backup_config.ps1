if (Test-Path 'c:\\ProgramData\\chocolatey\\config\\chocolatey.config') {
    Copy-Item -Path 'c:\\ProgramData\\chocolatey\\config\\chocolatey.config' -Destination 'c:\\ProgramData\\chocolatey\\config\\chocolatey.config.bkp'
}
