CHOCOLATEY_LATEST_INFO_URL = "https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/choco-pipeline-tests/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion"

def get_latest_chocholatey_download_url
  uri = URI.parse(CHOCOLATEY_LATEST_INFO_URL)

  response = Net::HTTP.get_response(uri)
  xml_str = Nokogiri::XML(response.body)

  src_url = xml_str.css('//feed//content').attr('src')

  return src_url
end

def install_chocolatey
  chocolatey_pp = <<-MANIFEST
  class {'chocolatey':
    chocolatey_download_url => 'file:///C:/chocolatey.nupkg',
    use_7zip                => false,
  }
  MANIFEST

  chocoVersion = /[0-9]+[\d'.']*/

  windows_agents.each do |agent|
    opts = {
      :acceptable_exit_codes => [0, 2]
    }

    curl_on(agent, "#{get_latest_chocholatey_download_url} > C:/chocolatey.nupkg")

    execute_manifest_on(agent, chocolatey_pp, opts) do |result|
      assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
    end

    on(agent, 'C:/ProgramData/chocolatey/bin/choco.exe -v', :acceptable_exit_codes => 0) do |result|
      assert_match(chocoVersion, result.stdout, 'Expected: ' + chocoVersion.to_s + ' but got ' + result.stdout)
    end
  end
end


def windows_agents
  agents.select { |agent| agent['platform'].include?('windows') }
end

def config_file_location
  'c:\\ProgramData\\chocolatey\\config\\chocolatey.config'
end

def backup_config
  windows_agents.each do |agent|
    backup_command = <<-COMMAND
    if (Test-Path #{config_file_location}) {
      Copy-Item -Path #{config_file_location} -Destination #{config_file_location}.bkp
    }
    COMMAND

    execute_powershell_script_on(agent, backup_command, :catch_failures => true)
  end
end

def reset_config
  windows_agents.each do |agent|
    backup_command = <<-COMMAND
    if (Test-Path #{config_file_location}.bkp) {
      Move-Item -Path #{config_file_location}.bkp -Destination #{config_file_location} -force
    }
    COMMAND

    execute_powershell_script_on(agent, backup_command, :catch_failures => true)
  end
end

def get_xml_value(xpath, file_text)
  doc = Nokogiri::XML(file_text)

  doc.xpath(xpath)
end

def config_content_command
  "cmd.exe /c \"type #{config_file_location}\""
end

