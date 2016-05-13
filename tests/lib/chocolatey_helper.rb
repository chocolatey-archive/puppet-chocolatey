require 'net/http'
require 'uri'
require 'nokogiri'

$chocolatey_latest_info_url = "http://nexus.delivery.puppetlabs.net/service/local/nuget/temp-build-tools/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion"

# Extract the url for the latest Puppet hosted version of Chocolatey
#
# ==== Returns
#
# +string+ - url from the feed/content->src of the $chocolatey_latest_info_url
#
# ==== Raises
#
# URI::InvalidURIError
#
# ==== Examples
#
# url = get_latest_chocholatey_download_url;

def get_latest_chocholatey_download_url()
  uri = URI.parse($chocolatey_latest_info_url)

  response = Net::HTTP.get_response(uri)
  xml_str = Nokogiri::XML(response.body)

  src_url = xml_str.css('//feed//content').attr('src')

  return src_url
end
