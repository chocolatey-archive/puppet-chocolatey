if (Test-Path 'c:\\ProgramData\\chocolatey\\config\\chocolatey.config.bkp' ) {
    Move-Item -Path 'c:\\ProgramData\\chocolatey\\config\\chocolatey.config.bkp' -Destination 'c:\\ProgramData\\chocolatey\\config\\chocolatey.config' -force
}